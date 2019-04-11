//
//  BaseMusicCell.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "BaseMusicCell.h"
#import "UIColor+Additional.h"
#import "Color.h"
#import <SDWebImage/SDWebImage.h>

@interface BaseMusicCell ()
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIImageView *albumImgView;
@end

@implementation BaseMusicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.songNameLabel = [[UILabel alloc] init];
        self.songNameLabel.font = [UIFont systemFontOfSize:19];
        self.songNameLabel.textColor = [UIColor colorWithHexString:Title_Color];
        [self addSubview:self.songNameLabel];
        
        self.descLabel = [[UILabel alloc] init];
        self.descLabel.font = [UIFont systemFontOfSize:15];
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
        
        self.albumImgView = [[UIImageView alloc] init];
        [self addSubview:self.albumImgView];
        
        _albumImgHeightAndWidth = 55;
        _playButtonHeightAndWidth = 40;
        _leftMargin = _rightMargin = 20;
        _labelWidth = 250;
    }
    return self;
}

- (void)setCellHeight:(float)cellHeight {
    _cellHeight = cellHeight;
    [self setNeedsLayout];
}

- (void)setMusic:(MusicItem *)music {
    _music = music;
    if (!_music)
        return;
    if (_music.albumImgUrl) {
        [self.albumImgView sd_setImageWithURL:[NSURL URLWithString:_music.albumImgUrl] placeholderImage:nil];
    }
    if (_music.songName) {
        self.songNameLabel.text = _music.songName;
    }
    if (_music.albumName && _music.singerName) {
        self.descLabel.text = [NSString stringWithFormat:@"%@ - %@", _music.singerName, _music.albumName];
    }
    self.playButton.enabled = !_music.payPlay;
    [self setNeedsLayout];
}

- (void)setLabelWidth:(float)labelWidth {
    _labelWidth = labelWidth;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    float albumImgViewY = (self.cellHeight - self.albumImgHeightAndWidth) / 2;
    self.albumImgView.frame = CGRectMake(self.leftMargin, albumImgViewY, self.albumImgHeightAndWidth, self.albumImgHeightAndWidth);
    
    [self.songNameLabel sizeToFit];
    self.songNameLabel.frame = CGRectMake(CGRectGetMaxX(self.albumImgView.frame) + 5, albumImgViewY, self.labelWidth, CGRectGetHeight(self.songNameLabel.frame));
    
    [self.descLabel sizeToFit];
    self.descLabel.frame = CGRectMake(CGRectGetMaxX(self.albumImgView.frame) + 5, CGRectGetMaxY(self.albumImgView.frame) - 18, self.labelWidth, CGRectGetHeight(self.descLabel.frame));
    
    self.playButton.frame = CGRectMake(CGRectGetWidth(self.frame) - self.rightMargin - self.playButtonHeightAndWidth, (self.cellHeight  - self.playButtonHeightAndWidth) / 2, self.playButtonHeightAndWidth, self.playButtonHeightAndWidth);
}

@end
