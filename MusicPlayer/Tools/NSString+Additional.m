//
//  NSString+Additional.m
//  MusicPlayer
//
//  Created by rod on 4/12/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "NSString+Additional.h"

@implementation NSString (Additional)
- (BOOL)isEmpty {
    if (self.length == 0 || [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
        return YES;
    else
        return NO;
}
@end
