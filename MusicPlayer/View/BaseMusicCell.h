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
@end

NS_ASSUME_NONNULL_END
