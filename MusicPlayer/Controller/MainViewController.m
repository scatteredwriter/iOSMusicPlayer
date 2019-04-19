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
#import "PopupPlayListView.h"
#import "UIViewController+Additional.h"

#define MUSIC_CONTROL_BAR_HEIGHT 70

@interface MainViewController ()
@property (nonatomic, strong) UIWindow *mainWindow;
@property (nonatomic, strong) PopupPlayListView *playListView;
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
    self.musicControlBar.delegate = self;
    [self.view addSubview:self.musicControlBar];
    
    self.playListView = [[PopupPlayListView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.playListView.closeCompleteBlock = ^{
        weakSelf.mainWindow.userInteractionEnabled = YES;
    };
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

- (void)presentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:^{
        self.mainWindow.hidden = YES;
        self.musicControlBar.hidden = YES;
    }];
}

- (void)presentViewControllerDismissed:(BOOL)dismissed {
    self.mainWindow.hidden = NO;
    self.musicControlBar.hidden = NO;
}

- (void)popupPlayListView {
    __weak typeof(self) weakSelf = self;
    [self.playListView popupView:^{
        weakSelf.mainWindow.userInteractionEnabled = NO;
    }];
}

@end
