//
//  MainTabBarController.m
//  MusicPlayer
//
//  Created by rod on 4/9/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "MainTabBarController.h"
#include "RankingTableController.h"

@interface MainTabBarController ()
@property (nonatomic, strong) UIView* musicBar;
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
