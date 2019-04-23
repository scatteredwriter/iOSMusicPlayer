//
//  DownloadedDAO.h
//  MusicPlayer
//
//  Created by rod on 4/22/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadedDAO : NSObject
@property (nonatomic, assign, readonly) BOOL hasProblem;
@property (nonatomic, assign, readonly) long count;
+ (DownloadedDAO *)sharedDownloadedDAO;
- (MusicItem *)getDownloadedBysongMid:(NSString *)songMid;
- (NSArray *)getAllDownloadeds;
- (int)addDownloaded:(MusicItem *)music;
- (int)removeDownloadedBysongMid:(NSString *)songMid;
@end

NS_ASSUME_NONNULL_END
