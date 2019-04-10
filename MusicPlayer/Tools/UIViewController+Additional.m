//
//  UIViewController+Additional.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "UIViewController+Additional.h"

@implementation UIViewController (Additional)
- (void)useNavigationBarWhiteTheme {
    [UINavigationBar appearance].translucent = NO;
    [UINavigationBar appearance].barTintColor = [UIColor whiteColor];
    [UINavigationBar appearance].tintColor = [UIColor blackColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
}

- (void)useNavigationBarBlackTheme {
    [UINavigationBar appearance].translucent = NO;
    [UINavigationBar appearance].barTintColor = [UIColor blackColor];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}
@end
