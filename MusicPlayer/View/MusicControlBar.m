//
//  MusicControlBar.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "MusicControlBar.h"
#import "UIColor+Additional.h"
#import "Color.h"

@implementation MusicControlBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:APP_Color];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
