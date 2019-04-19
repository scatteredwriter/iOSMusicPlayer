//
//  PlayListDAO.h
//  MusicPlayer
//
//  Created by rod on 4/18/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlayListDAO : NSObject
@property (nonatomic, assign, readonly) BOOL hasProblem;
+ (PlayListDAO *)sharedPlayListDAO;
- (MusicItem *)getMusicBysongMid:(NSString *)songMid;
- (NSArray *)getAllMusics;
- (int)addMusic:(MusicItem *)music;
- (int)removeMusicBysongMid:(NSString *)songMid;
@end

NS_ASSUME_NONNULL_END
