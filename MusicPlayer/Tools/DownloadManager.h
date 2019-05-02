//
//  DownloadManager.h
//  MusicPlayer
//
//  Created by rod on 4/22/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "MusicItem.h"

#define DOWNLOAD_DIRECTORY @"Download"
#define DOWNLOAD_MUSIC_DIRECTORY @"Musics"
#define DOWNLOAD_ALBUMIMG_DIRECTORY @"AlbumImgs"
#define DOWNLOAD_LYRIC_DIRECTORY @"Lyrics"

NS_ASSUME_NONNULL_BEGIN

@interface DownloadingItem : NSObject
@property (nonatomic, strong) MusicItem *music;
@property (nonatomic, assign) NSUInteger downloadTaskId;
@end

@interface DownloadManager : NSObject
@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong) NSHashTable *progressReportBlockTable;
@property (nonatomic, strong) NSHashTable *finishedHandlerBlockTable;
@property (nonatomic, strong ,readonly) NSMutableArray *downloadingArray;

@property (nonatomic, copy) NSString *downloadDirPath;
@property (nonatomic, copy) NSString *musicsDirPath;
@property (nonatomic, copy) NSString *albumImgsDirPath;
@property (nonatomic, copy) NSString *lyricDirPath;

+ (DownloadManager *)sharedDownloadManager;
- (void)newDownloadTask:(MusicItem *)music;
- (void)cancelDownloadTask:(MusicItem *)music;
- (void)addProgressReportBlock:(void (^)(NSProgress *progress, MusicItem *music))block;
- (void)addFinishedHandlerBlock:(void (^)(MusicItem *music))block;
- (NSString *)getMusicBymediaMid:(NSString *)mediaMid;
- (NSString *)getLyricBysongMid:(NSString *)songMid;
- (UIImage *)getAlbumImgBysongMid:(NSString *)songMid;
@end

NS_ASSUME_NONNULL_END
