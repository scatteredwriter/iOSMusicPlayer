//
//  PopupPlayListView.h
//  MusicPlayer
//
//  Created by rod on 4/18/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopupPlayListView : UIView <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) void (^closeCompleteBlock)(void);
- (void)popupView:(void (^)(void))completeBlock;
- (void)closeView;
@end

NS_ASSUME_NONNULL_END
