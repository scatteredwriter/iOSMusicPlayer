//
//  MusicControlBar.h
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface MusicControlBar : UIView
@property (nonatomic, strong) MusicItem *curMusic;
@end

NS_ASSUME_NONNULL_END
