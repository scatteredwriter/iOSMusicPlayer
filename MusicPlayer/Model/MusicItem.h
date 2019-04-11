//
//  MusicItem.h
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MusicItem : NSObject
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *singerName;
@property (nonatomic, copy) NSString *albumName;
@property (nonatomic, copy) NSString *albumImgUrl;
@property (nonatomic, copy) NSString *musicUrl;
@property (nonatomic, copy) NSString *songMid;
@property (nonatomic, copy) NSString *mediaMid;
@property (nonatomic, copy) NSString *albumMid;
@property (nonatomic, assign) BOOL payPlay;
@end

NS_ASSUME_NONNULL_END
