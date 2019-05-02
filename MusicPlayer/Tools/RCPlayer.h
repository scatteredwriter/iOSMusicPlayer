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

@protocol RCPlayerDelegate <NSObject>

@optional
- (void)RCPlayer:(id)player UpdateProgress:(CMTime)progress;
- (void)RCPlayer:(id)player UpdateMusic:(MusicItem *)newMusic Immediately:(BOOL)immediately;
- (void)RCPlayer:(id)player PlayOrPause:(BOOL)isPause;
- (void)RCPlayerPlayFinished:(id)player;

@end

typedef enum RCPlayerStatus : NSInteger {
    RCPlayerStatusUnknown = 0,
    RCPlayerStatusReadyToPlay = 1,
    RCPlayerStatusFailed = 2,
    RCPlayerStatusFinished = 3
} RCPlayerStatus;

@interface RCPlayer : NSObject <RCPlayerDelegate>
@property (nullable, nonatomic, strong) AVPlayerItem *curPlayerItem;
@property (nullable, nonatomic, strong) MusicItem *curMusic;
@property (nonatomic, readonly) RCPlayerStatus status;
@property (nonatomic, strong) NSHashTable *delegates;
@property (nonatomic, assign) BOOL isPause;
+ (RCPlayer *)sharedPlayer;
- (void)playMusic:(MusicItem *)music;
- (void)playMusic:(MusicItem *)music Immediately:(BOOL)immediately;
- (void)nextMusic;
- (void)previousMusic;
- (void)removeMusicInPlayList:(NSString *)songMid;
- (void)addDelegate:(id<RCPlayerDelegate>)delegate;
- (void)playOrPause;
- (void)seekToTime:(CMTime)time;
- (void)saveCurMusic;
@end

NS_ASSUME_NONNULL_END
