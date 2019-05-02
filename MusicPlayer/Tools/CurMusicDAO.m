//
//  CurMusicDAO.m
//  MusicPlayer
//
//  Created by rod on 4/18/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "CurMusicDAO.h"
#import "DownloadManager.h"

#define PLIST_FILE_NAME @"CurMusicList.plist"

static CurMusicDAO *_sharedInstance;

@interface CurMusicDAO ()
@property (nonatomic, copy) NSString *curMusicListPath;
@end

@implementation CurMusicDAO

+ (CurMusicDAO *)sharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[CurMusicDAO alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initPropertyList];
    }
    return self;
}

- (void)initPropertyList {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.curMusicListPath = [documentPath stringByAppendingPathComponent:PLIST_FILE_NAME];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL plistExists = [manager fileExistsAtPath:self.curMusicListPath];
    if (!plistExists) {
        NSLog(@"[CurMusicDAO initPropertyList]: %@ NOT EXIST! COPY IT FROM RESOURCE PATH NOW.", PLIST_FILE_NAME);
        NSBundle *currentBundle = [NSBundle bundleForClass:[CurMusicDAO class]];
        NSString *plistPathInBundle = [[currentBundle resourcePath] stringByAppendingPathComponent:PLIST_FILE_NAME];
        
        NSError *error;
        [manager copyItemAtPath:plistPathInBundle toPath:self.curMusicListPath error:&error];
        NSLog(@"[CurMusicDAO initPropertyList]: %@ COPY TO %@ COMPLETELY.", PLIST_FILE_NAME, self.curMusicListPath);
    }
}

- (void)updateCurMusic:(MusicItem *)music {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.curMusicListPath];
    dict[@"songName"] = music.songName;
    dict[@"singerName"] = music.singerName;
    dict[@"albumName"] = music.albumName;
    dict[@"albumImgUrl"] = music.albumImgUrl;
    dict[@"albumLargeImgUrl"] = music.albumLargeImgUrl;
    dict[@"songMid"] = music.songMid;
    dict[@"mediaMid"] = music.mediaMid;
    dict[@"albumMid"] = music.albumMid;
    dict[@"songId"] = [[NSNumber alloc] initWithInteger:music.songId];
    dict[@"isLocalFile"] = [[NSNumber alloc] initWithBool:music.isLocalFile];
    [dict writeToFile:self.curMusicListPath atomically:YES];
    NSLog(@"[CurMusicDAO updateCurMusic]: UPDATE CURRENT MUSIC (songName: %@) COMPLETELY.", music.songName);
}

- (MusicItem *)getCurMusic {
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:self.curMusicListPath];
    if (dict) {
        MusicItem *music = [[MusicItem alloc] init];
        music.songName = dict[@"songName"];
        music.singerName = dict[@"singerName"];
        music.albumName = dict[@"albumName"];
        music.albumImgUrl = dict[@"albumImgUrl"];
        music.albumLargeImgUrl = dict[@"albumLargeImgUrl"];
        music.songMid = dict[@"songMid"];
        music.mediaMid = dict[@"mediaMid"];
        music.albumMid = dict[@"albumMid"];
        music.songId = [((NSString *)dict[@"songId"]) integerValue];
        music.isLocalFile = [((NSString *)dict[@"isLocalFile"]) boolValue];
        if (!music.songMid || !music.songMid.length)
            return nil;
        if (music.isLocalFile) {
            music.musicUrl = [[DownloadManager sharedDownloadManager] getMusicBymediaMid:music.mediaMid];
        }
        NSLog(@"[CurMusicDAO getCurMusic]: GET CURRENT MUSIC (songName: %@) FROM %@ COMPLETELY.", music.songName, self.curMusicListPath);
        return music;
    }
    return nil;
}

@end
