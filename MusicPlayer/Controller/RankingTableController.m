//
//  RankingTableController.m
//  MusicPlayer
//
//  Created by rod on 4/9/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "RankingTableController.h"
#import "UIColor+Additional.h"
#import "RankingDetailTableController.h"

#define CELL_HEIGHT 200

@interface RankingCell : UITableViewCell
@property (nonatomic, assign) int index;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) UIButton* button;
@end

@interface RankingCell ()
@end

@implementation RankingCell
float _width = 0;
float _margin = 20;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.button = [UIButton buttonWithType:UIButtonTypeSystem];
        self.button.tag = -1;
        self.button.titleLabel.font = [UIFont systemFontOfSize:40];
        self.button.layer.cornerRadius = 10;
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateFocused];
        [self addSubview:self.button];
        self.layoutMargins = UIEdgeInsetsZero;
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    if (color != nil) {
        self.button.backgroundColor = color;
    }
}

- (void)setTitle:(NSString *)title {
    if(title != nil) {
        _title = title;
        [self.button setTitle:title forState:UIControlStateNormal];
        [self.button setTitle:title forState:UIControlStateFocused];
    }
}

- (void)setWidth:(float)width {
    _width = width;
    self.frame = CGRectMake(0, 0, _width, CELL_HEIGHT);
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = CGRectMake(_margin, _margin, _width, CELL_HEIGHT - _margin);
}

@end

@interface RankingTableController ()

@end

@implementation RankingTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:RankingCell.class forCellReuseIdentifier:@"RankingCell"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)buttonClickedHandler:(UIButton *)button {
    if (button.tag <= 0)
        return;
    RankingDetailTableController *controller = [[RankingDetailTableController alloc] initWithIndex:(int)button.tag];
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RankingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RankingCell" forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            cell.button.tag = 4;
            cell.title = @"流行指数";
            [cell setColor:[UIColor colorWithHexString:@"#CE6585"]];
            break;
        case 1:
            cell.button.tag = 26;
            cell.title = @"热歌榜";
            [cell setColor:[UIColor colorWithHexString:@"#5B83A1"]];
            break;
        case 2:
            cell.button.tag = 27;
            cell.title = @"新歌榜";
            [cell setColor:[UIColor colorWithHexString:@"#5AAFA3"]];
            break;
        case 3:
            cell.button.tag = 3;
            cell.title = @"欧美榜";
            [cell setColor:[UIColor colorWithHexString:@"#407A7D"]];
            break;
        default:
            return nil;
    }
    
    [cell.button addTarget:self action:@selector(buttonClickedHandler:) forControlEvents:UIControlEventTouchUpInside];
    [cell setWidth:(CGRectGetWidth(self.view.frame) - _margin * 2)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

@end
