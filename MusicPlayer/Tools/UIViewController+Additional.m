//
//  UIViewController+Additional.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "UIViewController+Additional.h"
#import "UIColor+Additional.h"
#import "Color.h"

@implementation UIViewController (Additional)
- (void)useNavigationBarWhiteTheme {
    [UINavigationBar appearance].translucent = YES;
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].tintColor = [UIColor colorWithHexString:APP_Color];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:APP_Color]};
}

- (void)useNavigationBarBlackTheme {
    [UINavigationBar appearance].translucent = NO;
    [UINavigationBar appearance].barTintColor = [UIColor colorWithHexString:APP_Color];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}
@end
