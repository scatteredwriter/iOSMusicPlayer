//
//  PopupPlayListView.m
//  MusicPlayer
//
//  Created by rod on 4/18/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "PopupPlayListView.h"
#import "UIColor+Additional.h"
#import "Color.h"
#import "PlayListDAO.h"
#import "RCPlayer.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define VIEW_HEIGHT (SCREEN_HEIGHT * 3 / 5)

@interface PopupPlayListViewCell : UITableViewCell
@property (nonatomic, copy) MusicItem *music;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) void (^removeButtonBlock)(NSString *songMid);
@end

@interface PopupPlayListViewCell ()
@property (nonatomic, strong) UILabel *songNameLabel;
@property (nonatomic, strong) UILabel *singerNameLabel;
@property (nonatomic, strong) UIImageView *playingImgView;
@property (nonatomic, strong) UIView *separatorView;
@end

@implementation PopupPlayListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.songNameLabel = [[UILabel alloc] init];
        self.songNameLabel.textColor = [UIColor whiteColor];
        self.songNameLabel.font = [UIFont systemFontOfSize:17];
        [self addSubview:self.songNameLabel];
        
        self.singerNameLabel = [[UILabel alloc] init];
        self.singerNameLabel.textColor = [UIColor colorWithHexString:Gary_Color];
        self.singerNameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.singerNameLabel];
        
        UIImage *playingImg = [UIImage imageNamed:@"playing"];
        self.playingImgView = [[UIImageView alloc] initWithImage:[playingImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        self.playingImgView.tintColor = [UIColor colorWithHexString:APP_Color];
        self.playingImgView.hidden = YES;
        [self addSubview:self.playingImgView];
        
        self.removeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.removeButton.tintColor = [UIColor colorWithHexString:Gary_Color];
        [self.removeButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [self.removeButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateHighlighted];
        self.removeButton.contentEdgeInsets = UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
        [self.removeButton addTarget:self action:@selector(removeButtonClickHandler) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.removeButton];
        
        self.separatorView = [[UIView alloc] init];
        self.separatorView.backgroundColor = [UIColor colorWithHexString:Gary_Color alpha:0.5];
        [self addSubview:self.separatorView];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat maxsongNameLabelWidth = 200;
    [self.songNameLabel sizeToFit];
    CGFloat songNameLabelWidth = CGRectGetWidth(self.songNameLabel.frame) > maxsongNameLabelWidth ? maxsongNameLabelWidth : CGRectGetWidth(self.songNameLabel.frame);
    self.songNameLabel.frame = CGRectMake(15, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.songNameLabel.frame)) / 2, songNameLabelWidth, CGRectGetHeight(self.songNameLabel.frame));
    
    CGFloat maxsingerNameLabelWidth = SCREEN_WIDTH - CGRectGetMaxX(self.songNameLabel.frame) - 10 - 5 - 25 - 35 - 5;
    [self.singerNameLabel sizeToFit];
    CGFloat singerNameLabelWidth = CGRectGetWidth(self.singerNameLabel.frame) > maxsingerNameLabelWidth ? maxsingerNameLabelWidth : CGRectGetWidth(self.singerNameLabel.frame);
    self.singerNameLabel.frame = CGRectMake(CGRectGetMaxX(self.songNameLabel.frame) + 10, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.singerNameLabel.frame)) / 2, singerNameLabelWidth, CGRectGetHeight(self.singerNameLabel.frame));
    
    self.playingImgView.frame = CGRectMake(CGRectGetMaxX(self.singerNameLabel.frame) + 5, (CGRectGetHeight(self.frame) - 25) / 2, 25, 25);
    self.removeButton.frame = CGRectMake(SCREEN_WIDTH - 35 - 5, CGRectGetMidY(self.singerNameLabel.frame) - 35 / 2, 35, 35);
    self.separatorView.frame = CGRectMake(15, CGRectGetHeight(self.frame) - 0.5, SCREEN_WIDTH - 15, 0.5);
}

- (void)setMusic:(MusicItem *)music {
    if (music) {
        _music = music;
        self.songNameLabel.text = _music.songName;
        self.singerNameLabel.text = _music.singerName;
        [self setNeedsLayout];
    }
}

- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    if (_isPlaying) {
        self.playingImgView.hidden = NO;
    }
    else {
        self.playingImgView.hidden = YES;
    }
}

- (void)removeButtonClickHandler {
    if (self.removeButtonBlock && self.music && self.music.songMid) {
        self.removeButtonBlock(self.music.songMid);
    }
}

@end

@interface PopupPlayListView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UITableView *contentTableView;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIView *whiteView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, copy) NSArray *musics;
@end

@implementation PopupPlayListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, VIEW_HEIGHT);
        
        self.bgView = [[UIView alloc] init];
        self.bgView.userInteractionEnabled = YES;
        self.bgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewGesture:)];
        [tapGesture setNumberOfTapsRequired:1];
        [self.bgView addGestureRecognizer:tapGesture];
        
        self.whiteView = [[UIView alloc] init];
        self.whiteView.backgroundColor = [UIColor colorWithHexString:@"#BBBBBB" alpha:0.4];
        [self addSubview:self.whiteView];
        
        self.effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        self.effectView.alpha = 0.9;
        [self addSubview:self.effectView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        self.titleLabel.text = @"播放列表";
        [self addSubview:self.titleLabel];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.closeButton.tintColor = [UIColor whiteColor];
        [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateHighlighted];
        [self.closeButton addTarget:self action:@selector(closeButtonClickHandler) forControlEvents:UIControlEventTouchUpInside];
        self.closeButton.contentEdgeInsets = UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
        [self addSubview:self.closeButton];
        
        self.separatorView = [[UIView alloc] init];
        self.separatorView.backgroundColor = [UIColor colorWithHexString:Gary_Color alpha:0.5];
        [self addSubview:self.separatorView];
        
        self.contentTableView = [[UITableView alloc] init];
        [self.contentTableView registerClass:PopupPlayListViewCell.class forCellReuseIdentifier:@"PopupPlayListViewCell"];
        self.contentTableView.delegate = self;
        self.contentTableView.dataSource = self;
        self.contentTableView.backgroundColor = [UIColor clearColor];
        self.contentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:self.contentTableView];
        
        self.emptyLabel = [[UILabel alloc] init];
        self.emptyLabel.textColor = [UIColor whiteColor];
        self.emptyLabel.font = [UIFont systemFontOfSize:15];
        self.emptyLabel.text = @"播放列表没有内容";
        self.emptyLabel.hidden = YES;
        [self addSubview:self.emptyLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    self.titleLabel.frame = CGRectMake(15, 15, CGRectGetWidth(self.titleLabel.frame), CGRectGetHeight(self.titleLabel.frame));
    self.closeButton.frame = CGRectMake(SCREEN_WIDTH - 35 - 5, CGRectGetMidY(self.titleLabel.frame) - 35 / 2, 35, 35);
    self.separatorView.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame) + 15, SCREEN_WIDTH, 0.5);
    self.contentTableView.frame = CGRectMake(0, CGRectGetMaxY(self.separatorView.frame), SCREEN_WIDTH, VIEW_HEIGHT - CGRectGetMaxY(self.separatorView.frame));
    [self.emptyLabel sizeToFit];
    self.emptyLabel.frame = CGRectMake((SCREEN_WIDTH - CGRectGetWidth(self.emptyLabel.frame)) / 2, (VIEW_HEIGHT - CGRectGetHeight(self.emptyLabel.frame)) / 2, CGRectGetWidth(self.emptyLabel.frame), CGRectGetHeight(self.emptyLabel.frame));
    self.whiteView.frame = self.bounds;
    self.effectView.frame = self.bounds;
    self.bgView.frame = [UIApplication sharedApplication].keyWindow.bounds;
}

- (void)p_initData {
    self.musics = [[PlayListDAO sharedPlayListDAO] getAllMusics];
    if (!self.musics || !self.musics.count) {
        NSLog(@"[PopupPlayListView p_initData]: NO DATA!");
        self.emptyLabel.hidden = NO;
        [self.contentTableView reloadData];
        return;
    }
    NSLog(@"[PopupPlayListView p_initData]: GET MUSICS.");
    self.emptyLabel.hidden = YES;
    [self.contentTableView reloadData];
}

- (void)popupView:(void (^)(void))completeBlock {
    self.alpha = 0.0;
    self.bgView.alpha = 0.0;
    self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, VIEW_HEIGHT);
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self.bgView];
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.0;
        self.bgView.alpha = 1.0;
        self.frame = CGRectMake(0, SCREEN_HEIGHT - VIEW_HEIGHT, SCREEN_WIDTH, VIEW_HEIGHT);
    } completion:^(BOOL finished) {
        if (completeBlock)
            completeBlock();
    }];
    [self p_initData];
    [self p_scrollTableView];
}

- (void)closeView {
    self.alpha = 1.0;
    self.bgView.alpha = 1.0;
    self.frame = CGRectMake(0, SCREEN_HEIGHT - VIEW_HEIGHT, SCREEN_WIDTH, VIEW_HEIGHT);
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
        self.bgView.alpha = 0.0;
        self.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, VIEW_HEIGHT);
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self removeFromSuperview];
    }];
    if (self.closeCompleteBlock)
        self.closeCompleteBlock();
}

- (void)reloadData {
    if (self.contentTableView) {
        [self.contentTableView reloadData];
    }
}

- (void)p_scrollTableView {
    if (self.musics && self.contentTableView && [RCPlayer sharedPlayer].curMusic) {
        for (int i = 0; i < self.musics.count; i++) {
            if ([((MusicItem *)self.musics[i]).songMid isEqualToString:[RCPlayer sharedPlayer].curMusic.songMid]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.contentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }
}

- (void)viewGesture:(UITapGestureRecognizer *)gesture {
    [self closeView];
}

- (void)closeButtonClickHandler {
    [self closeView];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.musics)
        return 0;
    return self.musics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PopupPlayListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopupPlayListViewCell" forIndexPath:indexPath];
    if (self.musics.count > indexPath.row) {
        int idx = (int)indexPath.row;
        MusicItem *item = self.musics[idx];
        cell.music = item;
        __weak typeof(self) weakSelf = self;
        cell.removeButtonBlock = ^(NSString *songMid) {
            [[RCPlayer sharedPlayer] removeMusicInPlayList:songMid];
            [weakSelf p_initData];
            [weakSelf p_scrollTableView];
        };
        if ([RCPlayer sharedPlayer].curMusic && [item.songMid isEqualToString:[RCPlayer sharedPlayer].curMusic.songMid]) {
            cell.isPlaying = YES;
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        else {
            cell.isPlaying = NO;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.contentTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row >= self.musics.count)
        return;
    
    int idx = (int)indexPath.row;
    MusicItem *item = self.musics[idx];
    if (item.payPlay)
        return;
    [[RCPlayer sharedPlayer] playMusic:item];
    [self closeView];
}

@end
