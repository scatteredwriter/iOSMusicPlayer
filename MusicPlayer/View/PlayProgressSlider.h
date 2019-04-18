//
//  PlayProgressSlider.h
//  MusicPlayer
//
//  Created by rod on 4/16/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PlayProgressSliderDelegate <NSObject>

- (void)playProgressSlider:(UIView *)playProgressSlider updateValue:(float)value;

@end

@interface PlayProgressSlider : UIView
@property (nonatomic, assign) CMTime curProgress;
@property (nonatomic, assign) CMTime maxProgress;
@property (nonatomic, weak) id<PlayProgressSliderDelegate> delegate;
- (void)updateCurValue:(float)value;
@end

NS_ASSUME_NONNULL_END
