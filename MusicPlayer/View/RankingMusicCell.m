//
//  RankingMusicCell.m
//  MusicPlayer
//
//  Created by rod on 4/11/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "RankingMusicCell.h"
#import "UIColor+Additional.h"
#import "Color.h"

@interface RankingMusicCell ()
@property (nonatomic, strong) UILabel *rankingLabel;
@end

@implementation RankingMusicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.rankingLabel = [[UILabel alloc] init];
        self.rankingLabel.font = [UIFont systemFontOfSize:20];
        self.rankingLabel.textAlignment = NSTextAlignmentCenter;
        self.rankingLabel.textColor = [UIColor colorWithHexString:DarkGary_Color];
        [self addSubview:self.rankingLabel];
        
        self.rankingLeftMargin = 2;
        self.labelWidth = 210;
    }
    return self;
}

- (void)setRanking:(int)ranking {
    _ranking = ranking;
    self.rankingLabel.text = [NSString stringWithFormat:@"%d", _ranking];
    if (_ranking > 0 && _ranking < 4) {
        self.rankingLabel.textColor = [UIColor colorWithHexString:Red_Color];
    }
    else {
        self.rankingLabel.textColor = [UIColor colorWithHexString:DarkGary_Color];
    }
    [self setNeedsLayout];
}

- (void)setRankingLeftMargin:(float)rankingLeftMargin {
    _rankingLeftMargin = rankingLeftMargin;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [self.rankingLabel sizeToFit];
    self.rankingLabel.frame = CGRectMake(self.rankingLeftMargin, (self.cellHeight - 20) / 2, 40, CGRectGetHeight(self.rankingLabel.frame));
    self.leftMargin = self.rankingLeftMargin * 2 + CGRectGetWidth(self.rankingLabel.frame);
    
    [super layoutSubviews];
}

@end
