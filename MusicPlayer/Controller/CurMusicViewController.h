//
//  CurMusicViewController.h
//  MusicPlayer
//
//  Created by rod on 4/15/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CurMusicViewControllerDelegate <NSObject>

- (void)curViewControllerDismissed:(BOOL)dismissed;

@end

@interface CurMusicViewController : UIViewController
@property (nonatomic, weak) id<CurMusicViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
