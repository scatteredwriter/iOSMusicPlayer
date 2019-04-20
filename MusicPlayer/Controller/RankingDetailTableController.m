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
#import "RankingMusicCell.h"
#import "MusicItem.h"
#import "RCPlayer.h"

#define CELL_HEIGHT 80

@interface RankingDetailTableController ()
@property (nonatomic, assign) int index;
@property (nonatomic, copy) NSArray *data;
@property (nonatomic, strong) NSMutableArray *musics;
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsZero;
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

- (void)getData {
    NSString *url = [NSString stringWithFormat:RankingAPI, self.index];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    RCHTTPSessionManager *manager = [RCHTTPSessionManager getRCHTTPSessionManager];
    __weak RankingDetailTableController *w_self = self;
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        w_self.data = responseObject[@"songlist"];
        [w_self createMusics];
        [w_self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error\n%@",error.localizedDescription);
    }];
    
}

- (void)createMusics {
    if (!self.data || self.data.count <= 0)
        return;
    self.musics = [[NSMutableArray alloc] initWithCapacity:self.data.count];
    for (int idx = 0; idx < self.data.count; idx++) {
        MusicItem *item = [[MusicItem alloc] init];
        item.songName = self.data[idx][@"data"][@"songname"];
        item.songMid = self.data[idx][@"data"][@"songmid"];
        item.songId = [((NSString *)self.data[idx][@"data"][@"songid"]) integerValue];
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
        
        [self.musics addObject:item];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.musics)
        return 0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    return self.musics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankingMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RankingMusicCell" forIndexPath:indexPath];
    cell.cellHeight = CELL_HEIGHT;
    if (self.musics.count > indexPath.row) {
        int idx = (int)indexPath.row;
        MusicItem *item = self.musics[idx];
        cell.music = item;
        cell.ranking = idx + 1;
        
        if (cell.music.payPlay) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= self.musics.count)
        return;
    
    int idx = (int)indexPath.row;
    MusicItem *item = self.musics[idx];
    if (item.payPlay)
        return;
    [[RCPlayer sharedPlayer] playMusic:item];
}

@end
