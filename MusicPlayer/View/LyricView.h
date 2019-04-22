//
//  LyricView.h
//  MusicPlayer
//
//  Created by rod on 4/20/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface LyricView : UIView
@property (nonatomic, strong) MusicItem *music;
- (void)clearLyric;
@end

NS_ASSUME_NONNULL_END
