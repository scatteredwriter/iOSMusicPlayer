//
//  MusicControlBar.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "MusicControlBar.h"
#import "UIColor+Additional.h"
#import "Color.h"
#import <SDWebImage/SDWebImage.h>

#define MUSIC_CONTROL_BAR_HEIGHT 70

@interface MusicControlBar ()
@property (nonatomic, strong) UIImageView *albumImgView;
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *playListButton;
@end

@implementation MusicControlBar
{
    UIView *_whiteView;
    UIVisualEffectView *_effectView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _effectView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _whiteView = [[UIView alloc] init];
        _whiteView.backgroundColor = [UIColor colorWithHexString:APP_Color];
        [self addSubview:_whiteView];
        [self addSubview:_effectView];
        
        self.songNameLabel = [[UILabel alloc] init];
        self.songNameLabel.font = [UIFont systemFontOfSize:15];
        self.songNameLabel.text = @"画沙";
        self.songNameLabel.textColor = [UIColor colorWithHexString:Title_Color];
        [self addSubview:self.songNameLabel];
        
        self.descLabel = [[UILabel alloc] init];
        self.descLabel.font = [UIFont systemFontOfSize:11];
        self.descLabel.text = @"周杰伦 - 画沙";
        self.descLabel.textColor = [UIColor colorWithHexString:Second_Color];
        [self addSubview:self.descLabel];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.playButton.tintColor = [UIColor colorWithHexString:APP_Color];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateDisabled];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateHighlighted];
        self.playButton.contentEdgeInsets = UIEdgeInsetsZero;
        self.playButton.enabled = NO;
        [self addSubview:self.playButton];
        
        self.playListButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.playListButton.tintColor = [UIColor colorWithHexString:APP_Color];
        [self.playListButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateDisabled];
        [self.playListButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateNormal];
        [self.playListButton setImage:[UIImage imageNamed:@"list"] forState:UIControlStateHighlighted];
        self.playListButton.contentEdgeInsets = UIEdgeInsetsZero;
        self.playListButton.enabled = NO;
        [self addSubview:self.playListButton];
        
        self.albumImgView = [[UIImageView alloc] init];
        [self.albumImgView sd_setImageWithURL:@"https://y.gtimg.cn/music/photo_new/T002R500x500M000002ldC3J1GUVlt.jpg?max_age=2592000"];
        [self addSubview:self.albumImgView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat albumImgHeightAndWidth = 50;
    CGFloat buttonHeightAndWidth = 40;
    CGFloat leftMargin = 20;
    CGFloat rightMargin = 10;
    CGFloat labelWidth = 320;
    
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

@end
