//
//  CurMusicDAO.h
//  MusicPlayer
//
//  Created by rod on 4/18/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface CurMusicDAO : NSObject
+ (CurMusicDAO *)sharedInstance;
- (void)updateCurMusic:(MusicItem *)music;
- (MusicItem *)getCurMusic;
@end

NS_ASSUME_NONNULL_END
