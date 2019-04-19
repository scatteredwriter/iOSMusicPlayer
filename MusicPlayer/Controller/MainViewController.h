//
//  MainViewController.h
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicControlBar.h"
#import "RCPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController <MusicControlBarDelegate, RCPlayerDelegate>
@property (nonnull, strong) MusicControlBar *musicControlBar;
@end

NS_ASSUME_NONNULL_END
