//
//  RCHTTPSessionManager.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "RCHTTPSessionManager.h"

@implementation RCHTTPSessionManager
+ (instancetype) getRCHTTPSessionManager {
    RCHTTPSessionManager *manager = [super manager];
    NSMutableSet *set = [NSMutableSet set];
    set.set = manager.responseSerializer.acceptableContentTypes;
    [set addObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = set;
    return manager;
}
@end
