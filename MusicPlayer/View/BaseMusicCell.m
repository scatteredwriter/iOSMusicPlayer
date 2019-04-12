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
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) UIImageView *albumImgView;
@end

@implementation BaseMusicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.songNameLabel = [[UILabel alloc] init];
        self.songNameLabel.font = [UIFont systemFontOfSize:15];
        self.songNameLabel.textColor = [UIColor colorWithHexString:Title_Color];
        [self addSubview:self.songNameLabel];
        
        self.descLabel = [[UILabel alloc] init];
        self.descLabel.font = [UIFont systemFontOfSize:11];
        self.descLabel.textColor = [UIColor colorWithHexString:Second_Color];
        [self addSubview:self.descLabel];
        
        self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.addButton.tintColor = [UIColor colorWithHexString:APP_Color];
        [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateDisabled];
        [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [self.addButton setImage:[UIImage imageNamed:@"plus"] forState:UIControlStateHighlighted];
        self.addButton.contentEdgeInsets = UIEdgeInsetsZero;
        self.addButton.enabled = NO;
        [self addSubview:self.addButton];
        
        self.albumImgView = [[UIImageView alloc] init];
        [self addSubview:self.albumImgView];
        
        _albumImgHeightAndWidth = 55;
        _addButtonHeightAndWidth = 40;
        _leftMargin = 20;
        _rightMargin = 10;
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
    self.songNameLabel.enabled = self.descLabel.enabled = self.addButton.enabled = !_music.payPlay;
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
    self.songNameLabel.frame = CGRectMake(CGRectGetMaxX(self.albumImgView.frame) + 10, albumImgViewY, self.labelWidth, CGRectGetHeight(self.songNameLabel.frame));
    
    [self.descLabel sizeToFit];
    self.descLabel.frame = CGRectMake(CGRectGetMaxX(self.albumImgView.frame) + 10, CGRectGetMaxY(self.albumImgView.frame) - 13, self.labelWidth, CGRectGetHeight(self.descLabel.frame));
    
    self.addButton.frame = CGRectMake(CGRectGetWidth(self.frame) - self.rightMargin - self.addButtonHeightAndWidth, (self.cellHeight  - self.addButtonHeightAndWidth) / 2, self.addButtonHeightAndWidth, self.addButtonHeightAndWidth);
}

@end
