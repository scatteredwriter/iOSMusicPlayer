//
//  DownloadViewController.m
//  MusicPlayer
//
//  Created by rod on 4/20/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadManager.h"
#import "DownloadedDAO.h"
#import "Color.h"
#import "UIColor+Additional.h"
#import "RCPlayer.h"

@interface DownloadTableViewCell : UITableViewCell
@property (nonatomic, strong) MusicItem *music;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, strong) void (^removeButtonHandlerBlock)(MusicItem *music);
@end

@interface DownloadTableViewCell ()
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *singerNameLabel;
@property (nonatomic, strong) UIView *separatorView;
@end

@implementation DownloadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.songNameLabel = [[UILabel alloc] init];
        self.songNameLabel.font = [UIFont systemFontOfSize:17];
        self.songNameLabel.textColor = [UIColor colorWithHexString:Title_Color];
        [self addSubview:self.songNameLabel];
        
        self.singerNameLabel = [[UILabel alloc] init];
        self.singerNameLabel.font = [UIFont systemFontOfSize:15];
        self.singerNameLabel.textColor = [UIColor colorWithHexString:Second_Color];
        [self addSubview:self.singerNameLabel];
        
        self.removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.removeButton.tintColor = [UIColor colorWithHexString:APP_Color];
        [self.removeButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateDisabled];
        [self.removeButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.removeButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateHighlighted];
        [self.removeButton addTarget:self action:@selector(removeButtonClickHandler) forControlEvents:UIControlEventTouchUpInside];
        self.removeButton.contentEdgeInsets = UIEdgeInsetsZero;
        [self addSubview:self.removeButton];
        
        self.separatorView = [[UIView alloc] init];
        self.separatorView.backgroundColor = [UIColor colorWithHexString:Gary_Color];
        [self addSubview:self.separatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.songNameLabel sizeToFit];
    CGFloat maxSongNameLabelWidth = CGRectGetWidth(self.songNameLabel.frame) > 200 ? 200 : CGRectGetWidth(self.songNameLabel.frame);
    self.songNameLabel.frame = CGRectMake(15, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.songNameLabel.frame)) / 2, maxSongNameLabelWidth, CGRectGetHeight(self.songNameLabel.frame));
    self.removeButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 35 - 15, (CGRectGetHeight(self.frame) - 35) / 2, 35, 35);
    [self.singerNameLabel sizeToFit];
    self.singerNameLabel.frame = CGRectMake(CGRectGetMaxX(self.songNameLabel.frame) + 10, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.singerNameLabel.frame)) / 2, CGRectGetMinX(self.removeButton.frame) - 10 - CGRectGetMaxX(self.songNameLabel.frame) - 10, CGRectGetHeight(self.singerNameLabel.frame));
    self.separatorView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
}

- (void)setMusic:(MusicItem *)music {
    _music = music;
    self.songNameLabel.text = _music.songName;
    self.singerNameLabel.text = _music.singerName;
    [self setNeedsLayout];
}

- (void)removeButtonClickHandler {
    if (self.removeButtonHandlerBlock && self.music) {
        self.removeButtonHandlerBlock(self.music);
    }
}

@end

@interface DownloadingTableViewCell : DownloadTableViewCell
- (void)setCurBytes:(int64_t)bytes byMusic:(MusicItem *)music;
- (void)setTotalBytes:(int64_t)bytes byMusic:(MusicItem *)music;
- (void)updateProgress:(Float64)progress byMusic:(MusicItem *)music;
@end

@interface DownloadingTableViewCell ()
@property (nonatomic, strong) UILabel *curBytesLabel;
@property (nonatomic, strong) UILabel *totalBytesLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation DownloadingTableViewCell
{
    int64_t _curBytes;
    int64_t _totalBytes;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.curBytesLabel = [[UILabel alloc] init];
        self.curBytesLabel.font = [UIFont systemFontOfSize:13];
        self.curBytesLabel.textColor = [UIColor colorWithHexString:APP_Color];
        [self addSubview:self.curBytesLabel];
        
        self.totalBytesLabel = [[UILabel alloc] init];
        self.totalBytesLabel.font = [UIFont systemFontOfSize:13];
        self.totalBytesLabel.textColor = [UIColor colorWithHexString:APP_Color];
        [self addSubview:self.totalBytesLabel];
        
        self.progressView = [[UIProgressView alloc] init];
        self.progressView.trackTintColor = [UIColor colorWithHexString:Gary_Color];
        self.progressView.tintColor = [UIColor colorWithHexString:APP_Color];
        [self addSubview:self.progressView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect songNameFrame = self.songNameLabel.frame;
    songNameFrame.origin.y -= 10;
    self.songNameLabel.frame = songNameFrame;
    
    CGRect singerNameFrame = self.singerNameLabel.frame;
    singerNameFrame.origin.y -= 10;
    self.singerNameLabel.frame = singerNameFrame;
    
    [self.curBytesLabel sizeToFit];
    self.curBytesLabel.frame = CGRectMake(15, CGRectGetHeight(self.frame) - CGRectGetHeight(self.curBytesLabel.frame) - 10, CGRectGetWidth(self.curBytesLabel.frame), CGRectGetHeight(self.curBytesLabel.frame));
    [self.totalBytesLabel sizeToFit];
    self.totalBytesLabel.frame = CGRectMake(CGRectGetMinX(self.removeButton.frame) - CGRectGetWidth(self.totalBytesLabel.frame) - 15, CGRectGetHeight(self.frame) - CGRectGetHeight(self.totalBytesLabel.frame) - 10, CGRectGetWidth(self.totalBytesLabel.frame), CGRectGetHeight(self.totalBytesLabel.frame));
    self.progressView.frame = CGRectMake(CGRectGetMaxX(self.curBytesLabel.frame) + 15, CGRectGetMidY(self.curBytesLabel.frame) - 2 / 2, CGRectGetMinX(self.totalBytesLabel.frame) - 15 - CGRectGetMaxX(self.curBytesLabel.frame) - 15, 2);
}

- (void)setCurBytes:(int64_t)bytes byMusic:(MusicItem *)music {
    if (music != self.music)
        return;
    _curBytes = bytes;
    self.curBytesLabel.text = [NSString stringWithFormat:@"%.2fMB", bytes / 1024.00 / 1024.00];
    [self setNeedsLayout];
}

- (void)setTotalBytes:(int64_t)bytes byMusic:(MusicItem *)music {
    if (music != self.music)
        return;
    _totalBytes = bytes;
    self.totalBytesLabel.text = [NSString stringWithFormat:@"%.2fMB", bytes / 1024.00 / 1024.00];
    [self setNeedsLayout];
}

- (void)updateProgress:(Float64)progress byMusic:(MusicItem *)music {
    [self setCurBytes:(_totalBytes * progress) byMusic:music];
    if (music != self.music)
        return;
    [self.progressView setProgress:progress animated:YES];
}

@end

typedef void (^progressUpdateBlock)(NSProgress *progress, MusicItem *music);
typedef void (^finishedHandlerBlock)(MusicItem *music);

@interface DownloadViewController ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UITableView *downloadedTableView;
@property (nonatomic, strong) UITableView *downloadingTableView;
@property (nonatomic, strong) NSArray *downloadingArrary;
@property (nonatomic, strong) NSArray *downloadedArrary;
@end

@implementation DownloadViewController
{
    progressUpdateBlock _progressUpdateBlock;
    finishedHandlerBlock _finishedHandlerBlock;
}

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
    [self.segmentedControl addTarget:self action:@selector(p_segmentControlValueChanged) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentedControl;
    
    self.downloadedTableView = [[UITableView alloc] init];
    [self.downloadedTableView registerClass:DownloadTableViewCell.class forCellReuseIdentifier:@"DownloadedTableViewCell"];
    self.downloadedTableView.delegate = self;
    self.downloadedTableView.dataSource = self;
    self.downloadedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.downloadedTableView];
    
    self.downloadingTableView = [[UITableView alloc] init];
    [self.downloadingTableView registerClass:DownloadingTableViewCell.class forCellReuseIdentifier:@"DownloadingTableViewCell"];
    self.downloadingTableView.delegate = self;
    self.downloadingTableView.dataSource = self;
    self.downloadingTableView.hidden = YES;
    self.downloadingTableView.allowsSelection = NO;
    self.downloadingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.downloadingTableView];
    
    __weak typeof(self) weakSelf = self;
    
    _progressUpdateBlock = ^(NSProgress *progress, MusicItem *music) {
        if (weakSelf.downloadingArrary) {
            for (int i = 0; i < weakSelf.downloadingArrary.count; i++) {
                DownloadingTableViewCell *cell = [weakSelf.downloadingTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                if (cell && cell.music == music) {
                    for (NSURLSessionDownloadTask *task in [DownloadManager sharedDownloadManager].sessionManager.downloadTasks) {
                        if (task.taskIdentifier == ((DownloadingItem *)weakSelf.downloadingArrary[i]).downloadTaskId) {
                            [cell setTotalBytes:task.countOfBytesExpectedToReceive byMusic:music];
                        }
                    }
                    [cell updateProgress:progress.fractionCompleted byMusic:music];
                    [weakSelf p_initData];
                    break;
                }
            }
        }
    };
    
    _finishedHandlerBlock = ^(MusicItem *music) {
        [weakSelf p_initData];
    };
    
    [[DownloadManager sharedDownloadManager] addProgressReportBlock:_progressUpdateBlock];
    [[DownloadManager sharedDownloadManager] addFinishedHandlerBlock:_finishedHandlerBlock];
    
    [self p_initData];
}

- (void)p_initData {
    DownloadManager *manager = [DownloadManager sharedDownloadManager];
    if (manager.downloadingArray) {
        _downloadingArrary = manager.downloadingArray;
    }
    else {
        _downloadingArrary = nil;
    }
    
    DownloadedDAO *downloadedDAO = [DownloadedDAO sharedDownloadedDAO];
    _downloadedArrary = [downloadedDAO getAllDownloadeds];
    
    [self.downloadingTableView reloadData];
    [self.downloadedTableView reloadData];
}

- (void)p_segmentControlValueChanged {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            self.downloadingTableView.hidden = YES;
            self.downloadedTableView.hidden = NO;
            break;
        case 1:
            self.downloadingTableView.hidden = NO;
            self.downloadedTableView.hidden = YES;
            break;
    }
    [self p_initData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self p_initData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.downloadedTableView.frame = self.view.bounds;
    self.downloadingTableView.frame = self.view.bounds;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.downloadingTableView && _downloadingArrary) {
        return _downloadingArrary.count;
    }
    else if (tableView == self.downloadedTableView && _downloadedArrary) {
        return _downloadedArrary.count;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.downloadingTableView && _downloadingArrary) {
        int idx = (int)indexPath.row;
        DownloadingItem *item = _downloadingArrary[idx];
        DownloadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadingTableViewCell" forIndexPath:indexPath];
        
        for (NSURLSessionDownloadTask *task in [DownloadManager sharedDownloadManager].sessionManager.downloadTasks) {
            if (task.taskIdentifier == item.downloadTaskId) {
                [cell setTotalBytes:task.countOfBytesExpectedToReceive byMusic:item.music];
                [cell setCurBytes:task.countOfBytesReceived byMusic:item.music];
            }
        }
        cell.music = item.music;
        __weak typeof(self) weakSelf = self;
        cell.removeButtonHandlerBlock = ^(MusicItem *music) {
            [[DownloadManager sharedDownloadManager] cancelDownloadTask:music];
            [weakSelf p_initData];
        };
        
        return cell;
    }
    else if (tableView == self.downloadedTableView && _downloadedArrary) {
        int idx = (int)indexPath.row;
        MusicItem *item = _downloadedArrary[idx];
        DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadedTableViewCell" forIndexPath:indexPath];
        
        cell.music = item;
        __weak typeof(self) weakSelf = self;
        cell.removeButtonHandlerBlock = ^(MusicItem *music) {
            if (!music)
                return;
            [[DownloadedDAO sharedDownloadedDAO] removeDownloadedBysongMid:music.songMid];
            [weakSelf p_initData];
        };
        
        return cell;
    }
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.downloadedTableView) {
        DownloadTableViewCell *cell = [self.downloadedTableView cellForRowAtIndexPath:indexPath];
        if (cell && cell.music) {
            [[RCPlayer sharedPlayer] playMusic:cell.music];
        }
    }
}

@end
