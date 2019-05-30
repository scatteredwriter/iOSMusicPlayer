//
//  RCPlayer.m
//  MusicPlayer
//
//  Created by rod on 4/13/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "RCPlayer.h"
#import "NotificationName.h"
#import "QQMusicAPI.h"
#import "RCHTTPSessionManager.h"
#import "CurMusicDAO.h"
#import "PlayListDAO.h"
#import "DownloadManager.h"
#import <SDWebImage/SDWebImage.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>

static RCPlayer *_sharedPlayer;
static AVPlayer *_player;
static id _periodicTimeObserver;
static NSString * const PlayerItemStatusContext = @"PlayerItemStatusContext";

@interface RCPlayer ()
@property (nonatomic, assign) BOOL playImmediately;
@end

@implementation RCPlayer

- (instancetype)init {
    if (self = [super init]) {
        if (!_player) {
            _player = [[AVPlayer alloc] init];
            _isPause = YES;
            _status = RCPlayerStatusUnknown;
            self.playImmediately = YES;
            self.delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];

            [self recoverCurMusic];
            
            AVAudioSession *session = [AVAudioSession sharedInstance];
            [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_periodicTimeObserver) {
        [_player removeTimeObserver:_periodicTimeObserver];
        _periodicTimeObserver = nil;
    }
}

+ (RCPlayer *)sharedPlayer {
    if (!_sharedPlayer) {
        _sharedPlayer = [[RCPlayer alloc] init];
    }
    return _sharedPlayer;
}

- (void)p_addTimeObserver {
    if(!_periodicTimeObserver) {
        // 监听播放进度，(1.0/1.0)秒监听一次
        __weak RCPlayer *weakSelf = self;
        _periodicTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            Float64 current = CMTimeGetSeconds(time);
            Float64 duration = CMTimeGetSeconds(self.curPlayerItem.duration);
            if (weakSelf.delegates.count && CMTIME_IS_VALID(time) && current && duration) {
                for (__weak id<RCPlayerDelegate> delegate in weakSelf.delegates) {
                    if(delegate && [delegate respondsToSelector:@selector(RCPlayer:UpdateProgress:)]) {
                        [delegate RCPlayer:self UpdateProgress:time];
                    }
                }
            }
        }];
    }
}

- (void)p_removeTimeObserver {
    if (_periodicTimeObserver) {
        [_player removeTimeObserver:_periodicTimeObserver];
        _periodicTimeObserver = nil;
    }
}

- (void)recoverCurMusic {
    MusicItem *music = [[CurMusicDAO sharedInstance] getCurMusic];
    if (music && music.mediaMid.length && music.songMid.length) {
        [self playMusic:music Immediately:NO];
        NSLog(@"[RCPlayer recoverCurMusic]: RECOVER CURRENT MUSIC SUCCESSFULLY.");
    }
    else {
        NSLog(@"[RCPlayer recoverCurMusic]: CANNOT RECOVER CURRENT MUSIC!");
    }
}

- (void)playMusic:(MusicItem *)music {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self setMusicUrl:music andDispatchGroup:group];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (music.isLocalFile) {
            music.musicUrl = [[DownloadManager sharedDownloadManager] getMusicBymediaMid:music.mediaMid];
        }
        if (music.musicUrl) {
            NSLog(@"[RCPlayer playMusic:]: get musicUrl.");
            [[PlayListDAO sharedPlayListDAO] addMusic:music];
            self.curMusic = music;
            if (music.isLocalFile) {
                [self createNewPlayerItem:[NSURL fileURLWithPath:music.musicUrl]];
            }
            else {
                [self createNewPlayerItem:[NSURL URLWithString:music.musicUrl]];
            }
        }
    });
}

- (void)playMusic:(MusicItem *)music Immediately:(BOOL)immediately {
    self.playImmediately = immediately;
    [self playMusic:music];
}

- (void)nextMusic {
    if (!self.curMusic)
        return;
    MusicItem *music = [[PlayListDAO sharedPlayListDAO] getNextMusicBysongMid:self.curMusic.songMid];
    if (music) {
        [self playMusic:music];
    }
}

- (void)previousMusic {
    if (!self.curMusic)
        return;
    MusicItem *music = [[PlayListDAO sharedPlayListDAO] getPreviousMusicBysongMid:self.curMusic.songMid];
    if (music) {
        [self playMusic:music];
    }
}

- (void)removeMusicInPlayList:(NSString *)songMid {
    if (self.curMusic && self.curPlayerItem && [self.curMusic.songMid isEqualToString:songMid]) {
        [self.curPlayerItem removeObserver:self forKeyPath:@"status"];
        MusicItem *nextMusic = [[PlayListDAO sharedPlayListDAO] getNextMusicBysongMid:self.curMusic.songMid];
        if (!nextMusic || [nextMusic.songMid isEqualToString:self.curMusic.songMid]) {
            _status = RCPlayerStatusFinished;
            [self p_pause];
            [_player seekToTime:CMTimeMake(0.0, 1.0)];
            self.curPlayerItem = nil;
            self.curMusic = nil;
            [self p_finished];
        }
        else {
            [self playMusic:nextMusic];
        }
    }
    [[PlayListDAO sharedPlayListDAO] removeMusicBysongMid:songMid];
}

- (void)playOrPause {
    NSLog(@"[RCPlayer playOrPause:]: get message.");
    if (self.curMusic && self.curPlayerItem && self.status == RCPlayerStatusFinished) {
        [self createNewPlayerItem:[NSURL URLWithString:self.curMusic.musicUrl]];
    }
    if (self.curPlayerItem && self.curPlayerItem.status == AVPlayerItemStatusReadyToPlay) {
        if (_isPause) {
            [self p_play];
        }
        else {
            [self p_pause];
        }
        [self configNowPlayingInfoCenter];
    }
}

- (void)addDelegate:(id<RCPlayerDelegate>)delegate {
    if(delegate)
        [self.delegates addObject:delegate];
}

- (void)seekToTime:(CMTime)time {
    if (!CMTIME_IS_VALID(time) || CMTimeGetSeconds(time) < 0)
        return;
    if (!self.curMusic || !self.curPlayerItem)
        return;
    if (CMTimeGetSeconds(self.curPlayerItem.duration) < CMTimeGetSeconds(time))
        return;
    if (self.status == RCPlayerStatusFinished) {
        // 恢复播放
        [self createNewPlayerItem:[NSURL URLWithString:self.curMusic.musicUrl]];
    }
    [_player seekToTime:time];
}

- (void)saveCurMusic {
    if (self.curMusic && self.status == RCPlayerStatusReadyToPlay) {
        [[CurMusicDAO sharedInstance] updateCurMusic:self.curMusic];
        NSLog(@"[RCPlayer saveCurMusic]: CURRENT MUSIC HAVE BEEN SAVED.");
    }
}

- (void)createNewPlayerItem:(NSURL *)musicUrl {
    self.curPlayerItem = [AVPlayerItem playerItemWithURL:musicUrl];
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew;
    
    // 监听AVPlayer status属性
    [self.curPlayerItem addObserver:self
                 forKeyPath:@"status"
                    options:options
                    context:nil];
    [_player replaceCurrentItemWithPlayerItem:self.curPlayerItem];
}

- (void)setMusicUrl:(MusicItem *)music andDispatchGroup:(dispatch_group_t)group {
    if (!music.songMid || !music.mediaMid || music.isLocalFile) {
        music.musicUrl = nil;
        dispatch_group_leave(group);
        return;
    }
    
    //没有musicUrl时
    if (!music.musicUrl) {
        RCHTTPSessionManager *manager = [RCHTTPSessionManager manager];
        NSString *url = [NSString stringWithFormat:VKeyAPI, music.songMid, music.mediaMid];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSData *data = (NSData *)responseObject;
            BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
            if (data.length == 0 || isSpace) {
                NSLog(@"error");
                dispatch_group_leave(group);
                return;
            }
            
            NSError *serializationError = nil;
            id resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
            
            if (!resp) {
                NSLog(@"error");
                dispatch_group_leave(group);
                return;
            }
            
            NSString *vkey = resp[@"data"][@"items"][0][@"vkey"];
            if (!vkey) {
                music.musicUrl = nil;
                dispatch_group_leave(group);
                return;
            }
            music.musicUrl = [NSString stringWithFormat:musicUrlAPI, music.mediaMid, vkey];
            NSLog(@"[RCPlayer setMusicUrl:andDispatchGroup:]: set musicUrl END.");
            dispatch_group_leave(group);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error:\n%@", error.localizedDescription);
            music.musicUrl = nil;
            dispatch_group_leave(group);
        }];
        NSLog(@"[RCPlayer setMusicUrl:andDispatchGroup:]: END.");
    }
    else {
        dispatch_group_leave(group);
    }
}

- (void)p_readyToPlay {
    NSLog(@"[RCPlayer]: RCPlayerStatusReadyToPlay.");
    _status = RCPlayerStatusReadyToPlay;
    // 开始处理远程控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self p_addTimeObserver];
    if (self.playImmediately) {
        [self p_play];
    }
    // 发送播放通知
    if (self.delegates.count > 0) {
        for (__weak id<RCPlayerDelegate> delegate in self.delegates) {
            if (delegate && [delegate respondsToSelector:@selector(RCPlayer:UpdateMusic:Immediately:)]) {
                [delegate RCPlayer:self UpdateMusic:self.curMusic Immediately:self.playImmediately];
            }
        }
    }
    // 监听播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // 处理远程控制
    [self remoteControlEventHandler];
    [self configNowPlayingInfoCenter];
    self.playImmediately = YES;
}

- (void)p_play {
    NSLog(@"[RCPlyer p_play]: PLAY.");
    [_player play];
    self.isPause = NO;
    if (self.delegates.count > 0) {
        for (__weak id<RCPlayerDelegate> delegate in self.delegates) {
            if (delegate && [delegate respondsToSelector:@selector(RCPlayer:PlayOrPause:)]) {
                [delegate RCPlayer:self PlayOrPause:self.isPause];
            }
        }
    }
}

- (void)p_pause {
    NSLog(@"[RCPlayer p_pause]: PAUSE.");
    [_player pause];
    self.isPause = YES;
    if (self.delegates.count > 0) {
        for (__weak id<RCPlayerDelegate> delegate in self.delegates) {
            if (delegate && [delegate respondsToSelector:@selector(RCPlayer:PlayOrPause:)]) {
                [delegate RCPlayer:self PlayOrPause:self.isPause];
            }
        }
    }
}

- (void)p_finished {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self p_removeTimeObserver];
    if (self.delegates.count > 0) {
        for (__weak id<RCPlayerDelegate> delegate in self.delegates) {
            if (delegate && [delegate respondsToSelector:@selector(RCPlayerPlayFinished:)]) {
                [delegate RCPlayerPlayFinished:self];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
        // Get the status change from the change dictionary
        NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
        if ([statusNumber isKindOfClass:[NSNumber class]]) {
            status = statusNumber.integerValue;
        }
        // Switch over the status
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
                // Ready to Play
                [self p_readyToPlay];
                break;
            case AVPlayerItemStatusFailed:
                // Failed. Examine AVPlayerItem.error
                _status = RCPlayerStatusFailed;
                NSLog(@"[RCPlayer]: RCPlayerStatusFailed!");
                break;
            case AVPlayerItemStatusUnknown:
                // Not ready
                _status = RCPlayerStatusUnknown;
                break;
        }
    }
}

- (void)playFinished:(NSNotification *)notification {
    NSLog(@"[RCPlayer playFinished:]: PLAY FINISHED.");
    if (self.curPlayerItem)
        @try {
            [self.curPlayerItem removeObserver:self forKeyPath:@"status"];
        } @catch (NSException *exception) {
            NSLog(@"[RCPlayer playFinished:]: remove observer forKeyPath status from self.curPlayItem FAILED!\n%@", exception);
        }
    _status = RCPlayerStatusFinished;
    if ([PlayListDAO sharedPlayListDAO].count > 0) {
        [self nextMusic];
    }
    else {
        [self p_finished];
    }
}

// 远程控制处理
- (void)remoteControlEventHandler
{
    // 直接使用sharedCommandCenter来获取MPRemoteCommandCenter的shared实例
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // 启用播放命令 (锁屏界面和上拉快捷功能菜单处的播放按钮触发的命令)
    commandCenter.playCommand.enabled = YES;
    // 为播放命令添加响应事件, 在点击后触发
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (self.curPlayerItem && self.curPlayerItem.status == AVPlayerItemStatusReadyToPlay) {
            [self p_play];
            [self configNowPlayingInfoCenter];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 播放, 暂停, 上下曲的命令默认都是启用状态, 即enabled默认为YES
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了暂停
        if (self.curPlayerItem && self.curPlayerItem.status == AVPlayerItemStatusReadyToPlay) {
            [self p_pause];
            [self configNowPlayingInfoCenter];
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了上一首
        [self previousMusic];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了下一首
        [self nextMusic];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 启用耳机的播放/暂停命令 (耳机上的播放按钮触发的命令)
    commandCenter.togglePlayPauseCommand.enabled = YES;
    // 为耳机的按钮操作添加相关的响应事件
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        // 进行播放/暂停的相关操作 (耳机的播放/暂停按钮)
        if (self.curPlayerItem && self.curPlayerItem.status == AVPlayerItemStatusReadyToPlay) {
            if (self.isPause) {
                [self p_play];
            }
            else {
                [self p_pause];
            }
        }
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}


// 配置播放信息
-(void)configNowPlayingInfoCenter {
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSMutableDictionary *musicInfo = [[NSMutableDictionary alloc] init];
        
        UIImage *image;
        if (self.curMusic.isLocalFile) {
            image = [[DownloadManager sharedDownloadManager] getAlbumImgBysongMid:self.curMusic.songMid];
        }
        else
        {
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.curMusic.albumImgUrl]];
            image = imageView.image;
        }
        MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage * _Nonnull(CGSize size) {
            return image;
        }];
        //歌曲名称
        [musicInfo setObject:self.curMusic.songName forKey:MPMediaItemPropertyTitle];
        //演唱者
        [musicInfo setObject:self.curMusic.singerName forKey:MPMediaItemPropertyArtist];
        //专辑名
        [musicInfo setObject:self.curMusic.albumName forKey:MPMediaItemPropertyAlbumTitle];
        //专辑缩略图
        [musicInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        //音乐当前已经播放时间
        [musicInfo setObject:@(CMTimeGetSeconds(self.curPlayerItem.currentTime)) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        //进度光标的速度 （这个随 自己的播放速率调整，我默认是原速播放）
        [musicInfo setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];
        //歌曲总时间设置
        [musicInfo setObject:@(CMTimeGetSeconds(self.curPlayerItem.duration)) forKey:MPMediaItemPropertyPlaybackDuration];
        //设置锁屏状态下屏幕显示音乐信息
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:musicInfo];
    }
}

@end
