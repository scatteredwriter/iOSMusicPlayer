//
//  RankingDetailTableController.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "UIColor+Additional.h"
#import "UIViewController+Additional.h"
#import "RankingDetailTableController.h"
#import <AFNetworking/AFNetworking.h>
#import "RCHTTPSessionManager.h"
#import "QQMusicAPI.h"
#import "RankingMusicCell.h"
#import "MusicItem.h"

#define CELL_HEIGHT 80

@interface RankingDetailTableController ()
@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSArray *data;
@end

@implementation RankingDetailTableController

- (instancetype)initWithIndex:(int)index {
    if (self = [super init]) {
        self.index = index;
        self.data = nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:RankingMusicCell.class forCellReuseIdentifier:@"RankingMusicCell"];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.allowsSelection = YES;
    switch (self.index) {
        case 4:
            self.title = @"流行指数";
//            [UINavigationBar appearance].barTintColor = [UIColor colorWithHexString:@"#CE6585"];
            break;
        case 26:
            self.title = @"热歌榜";
//            [UINavigationBar appearance].barTintColor = [UIColor colorWithHexString:@"#5B83A1"];
            break;
        case 27:
            self.title = @"新歌榜";
//            [UINavigationBar appearance].barTintColor = [UIColor colorWithHexString:@"#5AAFA3"];
            break;
        case 3:
            self.title = @"欧美榜";
//            [UINavigationBar appearance].barTintColor = [UIColor colorWithHexString:@"#407A7D"];
            break;
    }
    
    [self getData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)getData {
    NSString *api = [NSString stringWithFormat:RankingAPI, [NSString stringWithFormat:@"%d", self.index]];
    RCHTTPSessionManager *manager = [RCHTTPSessionManager getRCHTTPSessionManager];
    __weak RankingDetailTableController *w_self = self;
    [manager GET:api parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        w_self.data = responseObject[@"songlist"];
        [w_self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error\n%@",error.localizedDescription);
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.data)
        return 0;
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankingMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RankingMusicCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellHeight = CELL_HEIGHT;
    if (self.data && self.data.count > indexPath.row) {
        int idx = (int)indexPath.row;
        MusicItem *item = [[MusicItem alloc] init];
        item.songName = self.data[idx][@"data"][@"songname"];
        item.songMid = self.data[idx][@"data"][@"songmid"];
        item.mediaMid = self.data[idx][@"data"][@"strMediaMid"];
        item.albumMid = self.data[idx][@"data"][@"albummid"];
        item.albumName = self.data[idx][@"data"][@"albumname"];
        NSMutableString *singerName = [[NSMutableString alloc] init];
        for (NSDictionary *singerItem in self.data[idx][@"data"][@"singer"]) {
            [singerName appendFormat:@"%@/", singerItem[@"name"]];
        }
        [singerName replaceCharactersInRange:NSMakeRange(singerName.length - 1, 1) withString:@""];
        item.singerName = singerName;
        item.payPlay = [(NSString *)(self.data[idx][@"data"][@"pay"][@"payplay"]) boolValue];
        cell.music = item;
        cell.ranking = idx + 1;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
