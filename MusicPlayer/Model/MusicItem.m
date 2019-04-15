//
//  MusicItem.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "MusicItem.h"
#import "QQMusicAPI.h"

@implementation MusicItem

- (void)setAlbumMid:(NSString *)albumMid {
    _albumMid = albumMid;
    self.albumImgUrl = [NSString stringWithFormat:albumImgUrlAPI, 300, 300, _albumMid];
    self.albumLargeImgUrl = [NSString stringWithFormat:albumImgUrlAPI, 500, 500, _albumMid];
}

@end
