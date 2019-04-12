//
//  MainViewController.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "MainViewController.h"
#import "MainTabBarController.h"
#import "MusicControlBar.h"
#import "UIViewController+Additional.h"

#define MUSIC_CONTROL_BAR_HEIGHT 70

@interface MainViewController ()
@property (nonnull, strong) UIWindow *mainWindow;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self useNavigationBarBlackTheme];
    
    MainTabBarController *mainTabBarController = [[MainTabBarController alloc] init];
    self.mainWindow = [[UIWindow alloc] init];
    self.mainWindow.backgroundColor = [UIColor whiteColor];
    self.mainWindow.rootViewController = mainTabBarController;
    [self.mainWindow makeKeyAndVisible];
    [self.view addSubview:self.mainWindow];
    
    self.musicControlBar = [[MusicControlBar alloc] init];
    [self.view addSubview:self.musicControlBar];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.mainWindow.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - MUSIC_CONTROL_BAR_HEIGHT);
    self.musicControlBar.frame = CGRectMake(0, CGRectGetMaxY(self.mainWindow.frame), CGRectGetWidth(self.view.frame), MUSIC_CONTROL_BAR_HEIGHT);
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
