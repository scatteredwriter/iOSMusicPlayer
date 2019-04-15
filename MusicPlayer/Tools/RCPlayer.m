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
#import <SDWebImage/SDWebImage.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>

static RCPlayer *_sharedPlayer;
static AVPlayer *_player;
static id _periodicTimeObserver;
static NSString * const PlayerItemStatusContext = @"PlayerItemStatusContext";

@interface RCPlayer ()
@property (nonatomic, assign) Float64 curPosition;
@end

@implementation RCPlayer

- (instancetype)init {
    if (self = [super init]) {
        if (!_player) {
            _player = [[AVPlayer alloc] init];
            _isPause = YES;
            self.curPosition = 0.0;
            
            // 监听播放完成
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            
            // 监听音乐播放或暂停
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseCurMusic:) name:RCPlayerPlayOrPauseMusicNotification object:nil];
            
            if(!_periodicTimeObserver) {
                // 监听播放进度，(1.0/1.0)秒监听一次
                __weak RCPlayer *weakSelf = self;
                _periodicTimeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
                    Float64 current = CMTimeGetSeconds(time);
                    Float64 total = CMTimeGetSeconds(self.curPlayerItem.duration);
                    if (current) {
                        weakSelf.curPosition = current;
//                        weakSelf.playTime = [NSString stringWithFormat:@"%.f",current];
//                        weakSelf.playDuration = [NSString stringWithFormat:@"%.2f",total];
                    }
                }];
            }

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

- (void)playMusic:(MusicItem *)music {
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self setMusicUrl:music andDispatchGroup:group];
//    __weak RCPlayer *w_self = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (music.musicUrl) {
            NSLog(@"[RCPlayer playMusic:]: get musicUrl.");
            self.curMusic = music;
            [self createNewPlayerItem:[NSURL URLWithString:music.musicUrl]];
        }
    });
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

- (void)pauseCurMusic:(NSNotification *)notification {
//    if (!notification.userInfo)
//        return;
    NSLog(@"[RCPlayer pauseCurMusic:]: get message.");
    if (self.curPlayerItem && self.curPlayerItem.status == AVPlayerItemStatusReadyToPlay) {
//        BOOL isPuase = [notification.userInfo[@"isPause"] boolValue];
        if (_isPause) {
            NSLog(@"[RCPlayer pauseCurMusic:]: PLAY.");
            [_player play];
            self.isPause = NO;
        }
        else {
            NSLog(@"[RCPlayer pauseCurMusic:]: PAUSE.");
            [_player pause];
            self.isPause = YES;
        }
    } 
    [self configNowPlayingInfoCenter];
}

- (void)setMusicUrl:(MusicItem *)music andDispatchGroup:(dispatch_group_t)group {
    if (!music.songMid || !music.mediaMid) {
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

- (void)p_play {
    [_player play];
    self.isPause = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:RCPlayerPlayOrPauseUINotification object:nil userInfo:@{@"isPause":[NSNumber numberWithBool:self.isPause]}];
}

- (void)p_pause {
    [_player pause];
    self.isPause = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:RCPlayerPlayOrPauseUINotification object:nil userInfo:@{@"isPause":[NSNumber numberWithBool:self.isPause]}];
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
                _status = RCPlayerStatusReadyToPlay;
                [self p_play];
                //发送播放通知
                [[NSNotificationCenter defaultCenter] postNotificationName:RCPlayerUpdateCurrentMusicNotification object:nil userInfo:@{@"music":self.curMusic}];
                //处理远程控制
                [self remoteControlEventHandler];
                [self configNowPlayingInfoCenter];

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
    [self.curPlayerItem removeObserver:self forKeyPath:@"status"];
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
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了下一首
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
        UIImageView *imageView = [[UIImageView alloc] init];
        [imageView sd_setImageWithURL:[NSURL URLWithString:self.curMusic.albumImgUrl]];
        UIImage *image = imageView.image;
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
