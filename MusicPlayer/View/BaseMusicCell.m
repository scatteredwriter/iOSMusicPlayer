//
//  BaseMusicCell.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "BaseMusicCell.h"

@interface BaseMusicCell ()
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *singerNameLabel;
@property (nonatomic, strong) UILabel *albumNameLabel;
@property (nonatomic, strong) UIButton *playButton;
@end

@implementation BaseMusicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.songNameLabel = [[UILabel alloc] init];
        [self addSubview:self.songNameLabel];
        
        self.singerNameLabel = [[UILabel alloc] init];
        [self addSubview:self.singerNameLabel];
        
        self.albumNameLabel = [[UILabel alloc] init];
        [self addSubview:self.albumNameLabel];
        
        self.playButton = [[UIButton alloc] init];
        [self addSubview:self.playButton];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
