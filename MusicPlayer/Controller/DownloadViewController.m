//
//  DownloadViewController.m
//  MusicPlayer
//
//  Created by rod on 4/20/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "DownloadViewController.h"

@interface DownloadViewController ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *downloadedTableView;
@property (nonatomic, strong) UITableView *downloadingTableView;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *segments = @[@"已完成",@"下载中"];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segments];
    [self.segmentedControl sizeToFit];
    CGRect newFrame = self.segmentedControl.frame;
    newFrame.size.width = 170;
    newFrame.size.height += 5;
    self.segmentedControl.frame = newFrame;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = self.segmentedControl;
    
    self.downloadedTableView = [[UITableView alloc] init];
    self.downloadedTableView.delegate = self;
    self.downloadedTableView.dataSource = self;
    [self.view addSubview:self.downloadedTableView];
    
    self.downloadingTableView = [[UITableView alloc] init];
    self.downloadingTableView.delegate = self;
    self.downloadingTableView.dataSource = self;
    self.downloadingTableView.hidden = YES;
    [self.view addSubview:self.downloadingTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
