//
//  PlayProgressSlider.m
//  MusicPlayer
//
//  Created by rod on 4/16/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "PlayProgressSlider.h"
#import "Color.h"
#import "UIColor+Additional.h"

@interface RCSlider : UISlider

@end

@implementation RCSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 10;
    rect.size.width = rect.size.width + 20;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}

@end

@interface PlayProgressSlider ()
@property (nonatomic, strong) UILabel *curProgressLabel;
@property (nonatomic, strong) UILabel *maxProgressLabel;
@property (nonatomic, strong) RCSlider *slider;
@property (nonatomic, assign) BOOL isSlide;
@end

@implementation PlayProgressSlider

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.curProgressLabel = [[UILabel alloc] init];
        self.curProgressLabel.textColor = [UIColor whiteColor];
        self.curProgressLabel.font = [UIFont systemFontOfSize:12];
        self.curProgressLabel.text = @"00:00";
        [self addSubview:self.curProgressLabel];
        
        self.maxProgressLabel = [[UILabel alloc] init];
        self.maxProgressLabel.textColor = [UIColor whiteColor];
        self.maxProgressLabel.font = [UIFont systemFontOfSize:12];
        self.maxProgressLabel.text = @"00:00";
        [self addSubview:self.maxProgressLabel];
        
        self.slider = [[RCSlider alloc] init];
        self.slider.thumbTintColor = [UIColor colorWithHexString:APP_Color];
        [self.slider setThumbImage:[UIImage imageNamed:@"music_slider_circle"] forState:UIControlStateNormal];
        [self.slider setThumbImage:[UIImage imageNamed:@"music_slider_circle"] forState:UIControlStateHighlighted];
        self.slider.minimumTrackTintColor = [UIColor colorWithHexString:APP_Color];
        self.slider.maximumTrackTintColor = [UIColor colorWithHexString:DarkGary_Color];
        [self.slider addTarget:self action:@selector(p_valueChanged) forControlEvents:UIControlEventValueChanged];
        [self.slider addTarget:self action:@selector(p_valueFinishedChange) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.slider];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.curProgressLabel sizeToFit];
    self.curProgressLabel.frame = CGRectMake(0, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.curProgressLabel.frame)) / 2, CGRectGetWidth(self.curProgressLabel.frame), CGRectGetHeight(self.curProgressLabel.frame));
    
    [self.maxProgressLabel sizeToFit];
    self.maxProgressLabel.frame = CGRectMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.maxProgressLabel.frame), (CGRectGetHeight(self.frame) - CGRectGetHeight(self.maxProgressLabel.frame)) / 2, CGRectGetWidth(self.maxProgressLabel.frame), CGRectGetHeight(self.maxProgressLabel.frame));
    
    CGFloat sliderWidth = CGRectGetWidth(self.frame) - CGRectGetWidth(self.curProgressLabel.frame) - CGRectGetWidth(self.maxProgressLabel.frame) - 20 * 2;
    self.slider.frame = CGRectMake((CGRectGetWidth(self.frame) - sliderWidth) / 2, (CGRectGetHeight(self.frame) - 20) / 2, sliderWidth, 20);
}

- (void)setCurProgress:(CMTime)curProgress {
    _curProgress = curProgress;
    Float64 curProgInSecond = CMTimeGetSeconds(curProgress);
    int min = (int)(curProgInSecond / 60);
    int second = (int)(curProgInSecond - 60 * min);
    self.curProgressLabel.text = [NSString stringWithFormat:@"%02d:%02d",min, second];
    [self setNeedsLayout];
}

- (void)setMaxProgress:(CMTime)maxProgress {
    _maxProgress = maxProgress;
    Float64 maxProgInSecond = CMTimeGetSeconds(maxProgress);
    int min = (int)(maxProgInSecond / 60);
    int second = (int)(maxProgInSecond - 60 * min);
    self.maxProgressLabel.text = [NSString stringWithFormat:@"%02d:%02d",min, second];
    [self setNeedsLayout];
}

- (void)updateCurValue:(float)value {
    if (value > 1.0 || value < 0.0 || self.isSlide)
        return;
    self.slider.value = value;
}

- (void)p_valueChanged {
    self.isSlide = YES;
    self.curProgress = CMTimeMultiplyByFloat64(self.maxProgress, self.slider.value);
}

- (void)p_valueFinishedChange {
    NSLog(@"[PlayProgressSlider]: SLIDER VALUE CHANGED, value = %f", self.slider.value);
    if (self.delegate && [self.delegate respondsToSelector:@selector(playProgressSlider:updateValue:)]) {
        self.isSlide = NO;
        self.curProgress = CMTimeMultiplyByFloat64(self.maxProgress, self.slider.value);
        [self.delegate playProgressSlider:self updateValue:self.slider.value];
    }
}

@end
