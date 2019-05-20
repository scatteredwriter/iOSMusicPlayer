//
//  SearchTableController.m
//  MusicPlayer
//
//  Created by rod on 4/12/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "SearchTableController.h"
#import "UIColor+Additional.h"
#import "Color.h"
#import "QQMusicAPI.h"
#import "RCHTTPSessionManager.h"
#import "NSString+Additional.h"
#import "BaseMusicCell.h"
#import "MusicItem.h"
#import "RCPlayer.h"
#import "DownloadManager.h"
#import "DownloadedDAO.h"

#define CELL_HEIGHT 80

typedef void (^finishedHandlerBlock)(MusicItem *music);

@interface SearchTableController ()
@property (nonatomic, strong) UISearchBar *searchTitleView;
@property (nonatomic ,copy) NSDictionary *zhida;
@property (nonatomic, strong) NSMutableArray *musics;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation SearchTableController
{
    NSArray *_data;
    finishedHandlerBlock _finishedHandlerBlock;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:BaseMusicCell.class forCellReuseIdentifier:@"BaseMusicCell"];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.searchTitleView = [[UISearchBar alloc] init];
    self.searchTitleView.delegate = self;
    self.searchTitleView.tintColor = [UIColor colorWithHexString:APP_Color];
    self.navigationItem.titleView = self.searchTitleView;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelSearch)];
    
    self.page = -1;
    self.isLoading = NO;
    
    __weak SearchTableController *w_self = self;
    _finishedHandlerBlock = ^(MusicItem *music) {
        [w_self.tableView reloadData];
    };
    
    [[DownloadManager sharedDownloadManager] addFinishedHandlerBlock:_finishedHandlerBlock];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
}

- (void)cancelSearch {
    if (self.searchTitleView.canResignFirstResponder)
        [self.searchTitleView resignFirstResponder];
}

- (void)search:(NSString *)keyword {
    self.keyword = keyword;
    self.page = 1;
    self.musics = nil;
    
    __weak SearchTableController *w_self = self;
    [self getResp:self.keyword andPage:self.page andHandler:^(id resp) {
        [w_self loadData:resp];
    }];
}

- (void)getResp:(NSString *)keyword andPage:(int)page andHandler:(void (^)(id resp))completeHandler {
    if ([keyword isEmpty])
        return;
    
    NSLog(@"page = %d", page);
    NSString *url = [NSString stringWithFormat:SearchAPI, page, keyword];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    RCHTTPSessionManager *manager = [RCHTTPSessionManager getRCHTTPSessionManager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSData *data = (NSData *)responseObject;
        BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
        if (data.length == 0 || isSpace) {
            NSLog(@"error");
            return;
        }
        
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        str = [str stringByReplacingCharactersInRange:NSMakeRange(0, 9) withString:@""];
        str = [str stringByReplacingCharactersInRange:NSMakeRange(str.length - 1, 1) withString:@""];
        data = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *serializationError = nil;
        id resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
        
        if (!resp) {
            NSLog(@"error");
            return;
        }
        
        completeHandler(resp);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error\n%@", error.localizedDescription);
    }];
}

- (void)loadData:(id)data {
    self.zhida = data[@"data"][@"zhida"];
    _data = data[@"data"][@"song"][@"list"];
    [self createMusics];
    [self.tableView reloadData];
    if (_data.count < 20) //已经没有更多内容，令self.page = -1表示不需要下滑加载更多页
        self.page = -1;
    self.isLoading = NO;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)createMusics {
    if (!_data || _data.count <= 0)
        return;
    if (!self.musics)
        self.musics = [[NSMutableArray alloc] initWithCapacity:_data.count];
    for (int idx = 0; idx < _data.count; idx++) {
        MusicItem *item = [[MusicItem alloc] init];
        item.songName = _data[idx][@"title"];
        item.songMid = _data[idx][@"mid"];
        item.songId = [((NSString *)_data[idx][@"id"]) integerValue];
        item.mediaMid = _data[idx][@"file"][@"media_mid"];
        item.albumMid = _data[idx][@"album"][@"mid"];
        item.albumName = _data[idx][@"album"][@"title"];
        NSMutableString *singerName = [[NSMutableString alloc] init];
        for (NSDictionary *singerItem in _data[idx][@"singer"]) {
            [singerName appendFormat:@"%@/", singerItem[@"title"]];
        }
        [singerName replaceCharactersInRange:NSMakeRange(singerName.length - 1, 1) withString:@""];
        item.singerName = singerName;
        item.payPlay = [(NSString *)(_data[idx][@"pay"][@"pay_play"]) boolValue];
        
        [self.musics addObject:item];
    }
}

- (void)p_downloadMusic:(MusicItem *)music {
    if (!music)
        return;
    [[DownloadManager sharedDownloadManager] newDownloadTask:music];
}

#pragma mark - Search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *keyword = [NSString stringWithString:searchBar.text];
    if ([keyword isEmpty])
        return;
    [self search:searchBar.text];
    if ([searchBar canResignFirstResponder])
        [searchBar resignFirstResponder];
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
    BaseMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BaseMusicCell" forIndexPath:indexPath];
    cell.cellHeight = CELL_HEIGHT;
    if (self.musics.count > indexPath.row) {
        int idx = (int)indexPath.row;
        MusicItem *item = self.musics[idx];
        cell.music = item;
        if ([[DownloadedDAO sharedDownloadedDAO] getDownloadedBysongMid:cell.music.songMid]) {
            cell.downloadButtonEnabled = NO;
        } else {
            cell.downloadButtonEnabled = YES;
        }
        __weak typeof(self) weakSelf = self;
        cell.downloadButtonBlock = ^(MusicItem * _Nonnull music) {
            [weakSelf p_downloadMusic:music];
        };
        
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

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isLoading || [self.keyword isEmpty] || self.musics.count < 20 || self.page < 0)
        return;
    
    CGFloat targetHeight = scrollView.contentSize.height * 3 / 5;
    if (scrollView.contentOffset.y > targetHeight) {
        NSLog(@"达到界限\tscrollView.contentSize.height=%f\tscrollView.contentOffset.y=%f", scrollView.contentSize.height, scrollView.contentOffset.y);
        self.isLoading = YES;
        self.page++;
        
        __weak SearchTableController *w_self = self;
        [self getResp:self.keyword andPage:self.page andHandler:^(id resp) {
            [w_self loadData:resp];
        }];
    }
}

@end
