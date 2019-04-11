//
//  RankingMusicCell.h
//  MusicPlayer
//
//  Created by rod on 4/11/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseMusicCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface RankingMusicCell : BaseMusicCell

/*在RankingMusicCell中，BaseMusicCell的leftMargin属性无效，该属性值依赖rankingLeftMargin计算得出*/
@property (nonatomic, assign) float rankingLeftMargin;
@property (nonatomic, assign) int ranking;
@end

NS_ASSUME_NONNULL_END
