//
//  MainTabBarController.m
//  MusicPlayer
//
//  Created by rod on 4/9/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "MainTabBarController.h"
#import "RankingTableController.h"
#import "SearchTableController.h"
#import "DownloadViewController.h"
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
    
    SearchTableController *searchController = [[SearchTableController alloc] initWithStyle:UITableViewStylePlain];
    searchController.tabBarItem.image = [UIImage imageNamed:@"search"];
    searchController.tabBarItem.title = @"搜索";
    
    DownloadViewController *downloadController = [[DownloadViewController alloc] init];
    downloadController.tabBarItem.image = [UIImage imageNamed:@"music_library"];
    downloadController.tabBarItem.title = @"本地";
    
    self.viewControllers = @[
                             [[UINavigationController alloc] initWithRootViewController:rankingController],
                             [[UINavigationController alloc] initWithRootViewController:searchController],
                             [[UINavigationController alloc] initWithRootViewController:downloadController]
                             ];
    self.selectedIndex = 0;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

@end
