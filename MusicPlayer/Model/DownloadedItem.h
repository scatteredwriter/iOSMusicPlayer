//
//  DownloadedItem.h
//  MusicPlayer
//
//  Created by rod on 4/22/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadedItem : NSObject
@property (nonatomic, strong) MusicItem *music;
@property (nonatomic, copy) NSString *url;
@end

NS_ASSUME_NONNULL_END
