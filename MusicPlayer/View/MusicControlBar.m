//
//  MusicControlBar.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "MusicControlBar.h"
#import "UIColor+Additional.h"
#import "MusicItem.h"
#import "Color.h"
#import "NotificationName.h"
#import "MainViewController.h"
#import "CurMusicViewController.h"
#import <SDWebImage/SDWebImage.h>

#define MUSIC_CONTROL_BAR_HEIGHT 70

@interface MusicControlBar ()
@property (nonatomic, strong) UIImageView *albumImgView;
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *playListButton;
@property (nonatomic, assign) BOOL isPause;
@end

@implementation MusicControlBar
{
    UIView *_whiteView;
    UIVisualEffectView *_effectView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _whiteView = [[UIView alloc] init];
        _whiteView.backgroundColor = [UIColor colorWithHexString:APP_Color];
        [self addSubview:_whiteView];
        [self addSubview:_effectView];
        
        self.userInteractionEnabled = YES;
        self.isPause = YES;
        
        self.songNameLabel = [[UILabel alloc] init];
        self.songNameLabel.font = [UIFont systemFontOfSize:15];
        self.songNameLabel.textColor = [UIColor colorWithHexString:Title_Color];
        [self addSubview:self.songNameLabel];
        
        self.descLabel = [[UILabel alloc] init];
        self.descLabel.font = [UIFont systemFontOfSize:11];
        self.descLabel.textColor = [UIColor colorWithHexString:Second_Color];
        [self addSubview:self.descLabel];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.playButton.tintColor = [UIColor colorWithHexString:APP_Color];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateDisabled];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateHighlighted];
        self.playButton.contentEdgeInsets = UIEdgeInsetsZero;
        self.playButton.enabled = NO;
        [self.playButton addTarget:self action:@selector(playButtonClickHandler) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.playButton];
        
        self.playListButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.playListButton.tintColor = [UIColor colorWithHexString:APP_Color];
        [self.playListButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateDisabled];
        [self.playListButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
        [self.playListButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateHighlighted];
        self.playListButton.contentEdgeInsets = UIEdgeInsetsZero;
        [self addSubview:self.playListButton];
        
        self.albumImgView = [[UIImageView alloc] init];
        [self.albumImgView setImage:[UIImage imageNamed:@"cd"]];
        [self addSubview:self.albumImgView];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewGesture:)];
        [tapGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:tapGesture];

        // 监听播放歌曲更新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCurMusic:) name:RCPlayerUpdateCurrentMusicNotification object:nil];
        // 监听音乐播放或暂停
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePlayState:) name:RCPlayerPlayOrPauseUINotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat albumImgHeightAndWidth = 50;
    CGFloat buttonHeightAndWidth = 40;
    CGFloat leftMargin = 20;
    CGFloat rightMargin = 10;
    CGFloat labelWidth = 200;
    
    _effectView.frame = self.bounds;
    _whiteView.frame = CGRectMake(15, 25, CGRectGetWidth(self.frame) - 15 * 2, CGRectGetHeight(self.frame) - 25 * 2);
    
    float albumImgViewY = (MUSIC_CONTROL_BAR_HEIGHT - albumImgHeightAndWidth) / 2;
    self.albumImgView.frame = CGRectMake(leftMargin, albumImgViewY, albumImgHeightAndWidth, albumImgHeightAndWidth);
    
    [self.songNameLabel sizeToFit];
    self.songNameLabel.frame = CGRectMake(CGRectGetMaxX(self.albumImgView.frame) + 10, albumImgViewY, labelWidth, CGRectGetHeight(self.songNameLabel.frame));
    
    [self.descLabel sizeToFit];
    self.descLabel.frame = CGRectMake(CGRectGetMaxX(self.albumImgView.frame) + 10, CGRectGetMaxY(self.albumImgView.frame) - 13, labelWidth, CGRectGetHeight(self.descLabel.frame));
    
    self.playListButton.frame = CGRectMake(CGRectGetWidth(self.frame) - rightMargin - buttonHeightAndWidth, (MUSIC_CONTROL_BAR_HEIGHT - buttonHeightAndWidth) / 2, buttonHeightAndWidth, buttonHeightAndWidth);
    
    self.playButton.frame = CGRectMake(CGRectGetMinX(self.playListButton.frame) - buttonHeightAndWidth - 20, (MUSIC_CONTROL_BAR_HEIGHT - buttonHeightAndWidth) / 2, buttonHeightAndWidth, buttonHeightAndWidth);
}

- (void)viewGesture:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(presentViewController:)]) {
        CurMusicViewController *controller = [[CurMusicViewController alloc] init];
        controller.delegate = self;
        [self.delegate presentViewController:controller];
    }
}

- (void)curViewControllerDismissed:(BOOL)dismissed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(presentViewControllerDismissed:)]) {
        [self.delegate presentViewControllerDismissed:dismissed];
    }
}

- (void)updateCurMusic:(NSNotification *)notification {
    MusicItem *newMusic = notification.userInfo[@"music"];
    if (!newMusic)
        return;
    
    self.curMusic = newMusic;
    [self.albumImgView sd_setImageWithURL:[NSURL URLWithString:self.curMusic.albumImgUrl] placeholderImage:[UIImage imageNamed:@"cd"]];
    self.songNameLabel.text = self.curMusic.songName;
    self.descLabel.text = [NSString stringWithFormat:@"%@ - %@", self.curMusic.singerName, self.curMusic.albumName];
    [self p_updatePlayState];
    self.playButton.enabled = YES;
    [self setNeedsLayout];
}

- (void)updatePlayState:(NSNotification *)notification {
    BOOL isPause = [notification.userInfo[@"isPause"] boolValue];
    if (isPause) {
        [self p_updatePauseState];
    }
    else {
        [self p_updatePlayState];
    }
    return;
}

- (void)p_updatePlayState {
    [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateHighlighted];
    self.isPause = NO;
}

- (void)p_updatePauseState {
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateHighlighted];
    self.isPause = YES;
}

- (void)playButtonClickHandler {
    if (self.isPause) {
        [self p_updatePlayState];
    }
    else {
        [self p_updatePauseState];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:RCPlayerPlayOrPauseMusicNotification object:nil userInfo:nil];
}

@end
