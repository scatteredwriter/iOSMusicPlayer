//
//  RankingDetailTableController.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "UIColor+Additional.h"
#import "RankingDetailTableController.h"
#import <AFNetworking/AFNetworking.h>
#import "RCHTTPSessionManager.h"
#import "QQMusicAPI.h"
#import "BaseMusicCell.h"

@interface RankingDetailTableController ()
@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSDictionary *data;
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
    
    [self.tableView registerClass:BaseMusicCell.class forCellReuseIdentifier:@"BaseMusicCell"];
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
        NSLog(@"%@",responseObject);
        w_self.data = responseObject;
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
    return ((NSDictionary *)self.data[@"songlist"]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BaseMusicCell" forIndexPath:indexPath];
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
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
