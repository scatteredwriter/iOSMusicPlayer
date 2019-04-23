//
//  BaseMusicCell.h
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseMusicCell : UITableViewCell
@property (nonatomic, strong) MusicItem *music;
@property (nonatomic, assign) float leftMargin;
@property (nonatomic, assign) float rightMargin;
@property (nonatomic, assign) float cellHeight;
@property (nonatomic, assign) float addButtonHeightAndWidth;
@property (nonatomic, assign) float albumImgHeightAndWidth;
@property (nonatomic, assign) float labelWidth;
@property (nonatomic, assign) BOOL downloadButtonEnabled;
@property (nonatomic, strong) void (^downloadButtonBlock)(MusicItem *music);
@end

NS_ASSUME_NONNULL_END
