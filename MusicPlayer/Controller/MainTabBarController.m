//
//  MainTabBarController.m
//  MusicPlayer
//
//  Created by rod on 4/9/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "MainTabBarController.h"
#include "RankingTableController.h"
#import "UIColor+Additional.h"
#import "Color.h"

@interface MainTabBarController ()
@property (nonatomic, strong) UIView* musicBar;
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tabBar.tintColor = [UIColor colorWithHexString:APP_Color];
    
    RankingTableController *rankingController = [[RankingTableController alloc] initWithStyle:UITableViewStylePlain];
    rankingController.tabBarItem.image = [UIImage imageNamed:@"bar_chart"];
    rankingController.tabBarItem.title = @"榜单";
    self.viewControllers = @[
                             [[UINavigationController alloc] initWithRootViewController:rankingController]
                             ];
    self.selectedIndex = 0;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

@end
