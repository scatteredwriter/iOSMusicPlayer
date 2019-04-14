//
//  RCPlayer.h
//  MusicPlayer
//
//  Created by rod on 4/13/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum RCPlayerStatus : NSInteger {
    RCPlayerStatusUnknown = 0,
    RCPlayerStatusReadyToPlay = 1,
    RCPlayerStatusFailed = 2
} RCPlayerStatus;

@interface RCPlayer : NSObject
@property (nonatomic, strong) AVPlayerItem *curPlayerItem;
@property (nonatomic, strong) MusicItem *curMusic;
@property (nonatomic, readonly) RCPlayerStatus status;
@property (nonatomic, assign) BOOL isPause;
+ (RCPlayer *)sharedPlayer;
- (void)playMusic:(MusicItem *)music;
@end

NS_ASSUME_NONNULL_END
