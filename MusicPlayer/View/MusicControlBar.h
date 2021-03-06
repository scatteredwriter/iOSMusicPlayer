//
//  MusicControlBar.h
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicItem.h"
#import "CurMusicViewController.h"
#import "RCPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MusicControlBarDelegate <NSObject>

- (void)presentViewController:(UIViewController *)controller;
- (void)presentViewControllerDismissed:(BOOL)dismissed;
- (void)popupPlayListView;

@end

@interface MusicControlBar : UIView <CurMusicViewControllerDelegate, RCPlayerDelegate>
@property (nonatomic, weak) id<MusicControlBarDelegate> delegate;
@property (nonatomic, strong) MusicItem *curMusic;
@end

NS_ASSUME_NONNULL_END
