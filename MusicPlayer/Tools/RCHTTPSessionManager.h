//
//  RCHTTPSessionManager.h
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCHTTPSessionManager : AFHTTPSessionManager
+ (instancetype) getRCHTTPSessionManager;
@end

NS_ASSUME_NONNULL_END
