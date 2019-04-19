//
//  CurMusicViewController.m
//  MusicPlayer
//
//  Created by rod on 4/15/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "CurMusicViewController.h"
#import "UIColor+Additional.h"
#import "Color.h"
#import "RCPlayer.h"
#import "NotificationName.h"
#import "PlayProgressSlider.h"
#import "PopupPlayListView.h"
#import <SDWebImage/SDWebImage.h>

@interface CurMusicViewController ()
@property (nonatomic, strong) UIImageView *albumImgView;
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *singerLabel;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *playListButton;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *previousButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) PlayProgressSlider *progressSlider;
@property (nonatomic, strong) PopupPlayListView *playListView;
@property (nonatomic, assign) BOOL isPause;
@end

@implementation CurMusicViewController
{
    UIImageView *_bgImgView;
    UIVisualEffectView *_effectView;
    RCPlayer *_player;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[RCPlayer sharedPlayer] addDelegate:self];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _bgImgView = [[UIImageView alloc] init];
    _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self.view addSubview:_bgImgView];
    [self.view addSubview:_effectView];
    
    self.songNameLabel = [[UILabel alloc] init];
    self.songNameLabel.font = [UIFont systemFontOfSize:20];
    self.songNameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.songNameLabel];
    
    self.singerLabel = [[UILabel alloc] init];
    self.singerLabel.font = [UIFont systemFontOfSize:15];
    self.singerLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.singerLabel];
    
    self.albumNameLabel = [[UILabel alloc] init];
    self.albumNameLabel.font = [UIFont systemFontOfSize:17];
    self.albumNameLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.albumNameLabel];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.tintColor = [UIColor colorWithHexString:Gary_Color];
    [self.backButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateDisabled];
    [self.backButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateHighlighted];
    self.backButton.contentEdgeInsets = UIEdgeInsetsZero;
    [self.backButton addTarget:self action:@selector(backButtonClickHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backButton];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.playButton.tintColor = [UIColor whiteColor];
    self.playButton.contentEdgeInsets = UIEdgeInsetsZero;
//    self.playButton.enabled = NO;
    [self.playButton addTarget:self action:@selector(playButtonClickHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    
    self.playListButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.playListButton.tintColor = [UIColor whiteColor];
    [self.playListButton setImage:[UIImage imageNamed:@"player_list"] forState:UIControlStateDisabled];
    [self.playListButton setImage:[UIImage imageNamed:@"player_list"] forState:UIControlStateNormal];
    [self.playListButton setImage:[UIImage imageNamed:@"player_list"] forState:UIControlStateHighlighted];
    self.playListButton.contentEdgeInsets = UIEdgeInsetsZero;
    [self.playListButton addTarget:self action:@selector(playListButtonClickHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playListButton];
    
    self.downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.downloadButton.tintColor = [UIColor whiteColor];
    [self.downloadButton setImage:[UIImage imageNamed:@"player_download"] forState:UIControlStateDisabled];
    [self.downloadButton setImage:[UIImage imageNamed:@"player_download"] forState:UIControlStateNormal];
    [self.downloadButton setImage:[UIImage imageNamed:@"player_download"] forState:UIControlStateHighlighted];
    self.downloadButton.contentEdgeInsets = UIEdgeInsetsZero;
    [self.view addSubview:self.downloadButton];
    
    self.previousButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.previousButton.tintColor = [UIColor whiteColor];
    [self.previousButton setImage:[UIImage imageNamed:@"player_previous"] forState:UIControlStateDisabled];
    [self.previousButton setImage:[UIImage imageNamed:@"player_previous"] forState:UIControlStateNormal];
    [self.previousButton setImage:[UIImage imageNamed:@"player_previous"] forState:UIControlStateHighlighted];
    self.previousButton.contentEdgeInsets = UIEdgeInsetsZero;
    [self.view addSubview:self.previousButton];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nextButton.tintColor = [UIColor whiteColor];
    [self.nextButton setImage:[UIImage imageNamed:@"player_next"] forState:UIControlStateDisabled];
    [self.nextButton setImage:[UIImage imageNamed:@"player_next"] forState:UIControlStateNormal];
    [self.nextButton setImage:[UIImage imageNamed:@"player_next"] forState:UIControlStateHighlighted];
    self.nextButton.contentEdgeInsets = UIEdgeInsetsZero;
    [self.view addSubview:self.nextButton];
    
    self.albumImgView = [[UIImageView alloc] init];
    [self.albumImgView setImage:[UIImage imageNamed:@"player_cd"]];
    [self.view addSubview:self.albumImgView];
    
    self.progressSlider = [[PlayProgressSlider alloc] init];
    self.progressSlider.delegate = self;
    [self.view addSubview:self.progressSlider];
    
    self.playListView = [[PopupPlayListView alloc] init];
//    __weak typeof(self) weakSelf = self;
    self.playListView.closeCompleteBlock = ^{
    };
    
    [self p_initPlayState];
}

- (void)p_initPlayState {
    _player = [RCPlayer sharedPlayer];
    self.isPause = _player.isPause;
    if (self.isPause) {
        [self.playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateHighlighted];
    }
    else {
        [self.playButton setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateHighlighted];
    }
    if (_player.curMusic && _player.curPlayerItem) {
        [_bgImgView sd_setImageWithURL:[NSURL URLWithString:_player.curMusic.albumImgUrl] placeholderImage:[UIImage imageNamed:@"player_cd"]];
        [self.albumImgView sd_setImageWithURL:[NSURL URLWithString:_player.curMusic.albumLargeImgUrl] placeholderImage:[UIImage imageNamed:@"player_cd"]];
        self.songNameLabel.text = _player.curMusic.songName;
        self.singerLabel.text = _player.curMusic.singerName;
        self.albumNameLabel.text = _player.curMusic.albumName;
        self.playButton.enabled = YES;
        [self.progressSlider setCurProgress:_player.curPlayerItem.currentTime];
        [self.progressSlider setMaxProgress:_player.curPlayerItem.duration];
        if ([RCPlayer sharedPlayer].status == RCPlayerStatusFinished) {
            [self.progressSlider updateCurValue:1.0];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _effectView.frame = self.view.bounds;
    _bgImgView.frame = self.view.bounds;
    
    self.backButton.frame = CGRectMake(15, 25, 40, 40);
    
    CGFloat labelMaxWidth = CGRectGetWidth(self.view.frame) - (CGRectGetMaxX(self.backButton.frame) + 20) * 2;
    [self.songNameLabel sizeToFit];
    CGFloat songNameLabelX = CGRectGetWidth(self.songNameLabel.frame) > labelMaxWidth ? (CGRectGetMaxX(self.backButton.frame) + 20) : (CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.songNameLabel.frame)) / 2;
    CGFloat songNameLabelWidth = CGRectGetWidth(self.songNameLabel.frame) > labelMaxWidth ? labelMaxWidth : CGRectGetWidth(self.songNameLabel.frame);
    self.songNameLabel.frame = CGRectMake(songNameLabelX, CGRectGetMinY(self.backButton.frame) + 8, songNameLabelWidth, CGRectGetHeight(self.songNameLabel.frame));
    
    [self.singerLabel sizeToFit];
    CGFloat singerLabelX = CGRectGetWidth(self.singerLabel.frame) > labelMaxWidth ? (CGRectGetMaxX(self.backButton.frame) + 20) : (CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.singerLabel.frame)) / 2;
    CGFloat singerLabelWidth = CGRectGetWidth(self.singerLabel.frame) > labelMaxWidth ? labelMaxWidth : CGRectGetWidth(self.singerLabel.frame);
    self.singerLabel.frame = CGRectMake(singerLabelX, CGRectGetMaxY(self.songNameLabel.frame) + 10, singerLabelWidth, CGRectGetHeight(self.singerLabel.frame));
    
    CGSize albumImgSize = CGSizeMake(300, 300);
    self.albumImgView.frame = CGRectMake((CGRectGetWidth(self.view.frame) - albumImgSize.width) / 2, (CGRectGetHeight(self.view.frame) - albumImgSize.height) / 2, albumImgSize.width, albumImgSize.height);
    
    [self.albumNameLabel sizeToFit];
    CGFloat albumNameLabelX = CGRectGetWidth(self.albumNameLabel.frame) > labelMaxWidth ? (CGRectGetMaxX(self.backButton.frame) + 20) : (CGRectGetWidth(self.view.frame) - CGRectGetWidth(self.albumNameLabel.frame)) / 2;
    CGFloat albumNameLabelWidth = CGRectGetWidth(self.albumNameLabel.frame) > labelMaxWidth ? labelMaxWidth : CGRectGetWidth(self.albumNameLabel.frame);
    self.albumNameLabel.frame = CGRectMake(albumNameLabelX, CGRectGetMaxY(self.albumImgView.frame) + 15, albumNameLabelWidth, CGRectGetHeight(self.albumNameLabel.frame));
    
    CGSize playButtonSize = CGSizeMake(40, 40);
    self.playButton.frame = CGRectMake((CGRectGetWidth(self.view.frame) - playButtonSize.width) / 2, CGRectGetMaxY(self.view.frame) - 20 - playButtonSize.height, playButtonSize.width, playButtonSize.height);
    
    CGSize buttonSize = CGSizeMake(25, 25);
    self.playListButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - buttonSize.width - 30, CGRectGetMidY(self.playButton.frame) - buttonSize.height / 2, buttonSize.width, buttonSize.height);
    self.downloadButton.frame = CGRectMake(30, CGRectGetMidY(self.playButton.frame) - buttonSize.height / 2, buttonSize.width, buttonSize.height);
    
    CGFloat previousButtonX = CGRectGetMaxX(self.downloadButton.frame) + (CGRectGetMinX(self.playButton.frame) - CGRectGetMaxX(self.downloadButton.frame) - buttonSize.width) / 2;
    self.previousButton.frame = CGRectMake(previousButtonX, CGRectGetMidY(self.playButton.frame) - buttonSize.height / 2, buttonSize.width, buttonSize.height);
    
    CGFloat nextButtonX = CGRectGetMaxX(self.playButton.frame) + (CGRectGetMinX(self.playListButton.frame) - CGRectGetMaxX(self.playButton.frame) - buttonSize.width) / 2;
    self.nextButton.frame = CGRectMake(nextButtonX, CGRectGetMidY(self.playButton.frame) - buttonSize.height / 2, buttonSize.width, buttonSize.height);
    
    self.progressSlider.frame = CGRectMake(15, CGRectGetMinY(self.playButton.frame) - 50, CGRectGetWidth(self.view.frame) - 15 * 2, 20);
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)p_updatePlayState {
    [self.playButton setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateHighlighted];
    self.playButton.enabled = YES;
    self.isPause = NO;
}

- (void)p_updatePauseState {
    [self.playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateHighlighted];
    self.playButton.enabled = YES;
    self.isPause = YES;
}

- (void)playButtonClickHandler {
    [[RCPlayer sharedPlayer] playOrPause];
}

- (void)backButtonClickHandler {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(curViewControllerDismissed:)]) {
        [self.delegate curViewControllerDismissed:YES];
    }
}

- (void)playListButtonClickHandler {
    [self.playListView popupView:^{
    }];
}

#pragma mark - RCPlayer delegate

- (void)RCPlayer:(id)player UpdateProgress:(CMTime)progress {
    Float64 current = CMTimeGetSeconds(progress);
    Float64 duration = CMTimeGetSeconds([RCPlayer sharedPlayer].curPlayerItem.duration);
    if (CMTIME_IS_VALID(progress) && current && duration) {
        [self.progressSlider setCurProgress:progress];
        [self.progressSlider updateCurValue:(current / duration)];
    }
}

- (void)RCPlayer:(id)player UpdateMusic:(nonnull MusicItem *)newMusic Immediately:(BOOL)immediately {
    if (newMusic) {
        [self.progressSlider setCurProgress:CMTimeMake(0.0, 1.0)];
        [self.progressSlider updateCurValue:0];
        [self.albumImgView sd_setImageWithURL:[NSURL URLWithString:newMusic.albumLargeImgUrl] placeholderImage:[UIImage imageNamed:@"player_cd"]];
        [_bgImgView sd_setImageWithURL:[NSURL URLWithString:newMusic.albumLargeImgUrl] placeholderImage:[UIImage imageNamed:@"player_cd"]];
        self.songNameLabel.text = newMusic.songName;
        self.singerLabel.text = newMusic.singerName;
        self.albumNameLabel.text = newMusic.albumName;
        self.playButton.enabled = YES;
        if (immediately) {
            [self p_updatePlayState];
        }
        [self viewWillLayoutSubviews];
    }
}

- (void)RCPlayer:(id)player PlayPause:(BOOL)isPause {
    if (isPause) {
        [self p_updatePauseState];
    }
    else {
        [self p_updatePlayState];
    }
}

- (void)RCPlayerPlayFinished:(id)player {
    [self p_updatePauseState];
//    self.playButton.enabled = NO;
}

#pragma mark - PlayProgressSlider delegate

- (void)playProgressSlider:(UIView *)playProgressSlider updateValue:(float)value {
    if (value > 0.0 && [RCPlayer sharedPlayer].curPlayerItem) {
        [[RCPlayer sharedPlayer] seekToTime:CMTimeMultiplyByFloat64([RCPlayer sharedPlayer].curPlayerItem.duration, value)];
    }
}

@end
