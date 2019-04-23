//
//  DownloadManager.m
//  MusicPlayer
//
//  Created by rod on 4/22/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "DownloadManager.h"
#import "MusicItem.h"
#import "DownloadedItem.h"
#import "QQMusicAPI.h"
#import "DownloadedDAO.h"

@implementation DownloadingItem

@end

static DownloadManager *_sharedDownloadManager;

@interface DownloadManager ()

@end

@implementation DownloadManager

+ (DownloadManager *)sharedDownloadManager {
    if (!_sharedDownloadManager) {
        _sharedDownloadManager = [[DownloadManager alloc] init];
    }
    return _sharedDownloadManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.progressReportBlockTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:10];
        self.finishedHandlerBlockTable = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory capacity:10];
        _downloadingArray = [[NSMutableArray alloc] initWithCapacity:10];
        
        self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        self.downloadDirPath = [documentPath stringByAppendingPathComponent:DOWNLOAD_DIRECTORY];
        self.musicsDirPath = [self.downloadDirPath stringByAppendingPathComponent:DOWNLOAD_MUSIC_DIRECTORY];
        self.albumImgsDirPath = [self.downloadDirPath stringByAppendingPathComponent:DOWNLOAD_ALBUMIMG_DIRECTORY];
        self.lyrisDirPath = [self.lyrisDirPath stringByAppendingPathComponent:DOWNLOAD_LYRIC_DIRECTORY];
        
        NSFileManager *filemanager = [[NSFileManager alloc] init];
        if (![filemanager fileExistsAtPath:self.musicsDirPath]) {
            [filemanager createDirectoryAtPath:self.musicsDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![filemanager fileExistsAtPath:self.albumImgsDirPath]) {
            [filemanager createDirectoryAtPath:self.albumImgsDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if (![filemanager fileExistsAtPath:self.lyrisDirPath]) {
            [filemanager createDirectoryAtPath:self.lyrisDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)newDownloadTask:(MusicItem *)music {
    if (!music || !music.songMid || !music.mediaMid)
        return;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self p_setMusicUrl:music andDispatchGroup:group];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (music.musicUrl) {
            NSLog(@"[DownloadManager newDownloadTask:]: get musicUrl.");
        }
        
        NSURL *url = [NSURL URLWithString:music.musicUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSString *filePath = [self.musicsDirPath stringByAppendingPathComponent:url.lastPathComponent];
        __weak typeof(self) weakSelf = self;
        __weak MusicItem * weakMusic = music;
        NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            // 下载进度报告
            NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
            
            if (weakSelf.progressReportBlockTable.count) {
                for (void (^block)(NSProgress *progress, MusicItem *music) in weakSelf.progressReportBlockTable) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(downloadProgress, weakMusic);
                    });
                }
            }
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:filePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            // 下载完成
            NSLog(@"下载完成");
            
            weakMusic.musicUrl = [filePath lastPathComponent];
            NSLog(@"文件路径: %@", filePath);
            [[DownloadedDAO sharedDownloadedDAO] addDownloaded:weakMusic];
            
            for (DownloadingItem *item in weakSelf.downloadingArray) {
                if (item.music == music) {
                    [weakSelf.downloadingArray removeObject:item];
                    break;
                }
            }
            if (weakSelf.finishedHandlerBlockTable.count) {
                for (void (^block)(MusicItem *music) in weakSelf.finishedHandlerBlockTable) {
                    block(weakMusic);
                }
            }
        }];
        
        DownloadingItem *downloading = [[DownloadingItem alloc] init];
        downloading.music = music;
        downloading.downloadTaskId = downloadTask.taskIdentifier;
        [self.downloadingArray addObject:downloading];
        
        [downloadTask resume];
    });
}

- (void)cancelDownloadTask:(MusicItem *)music {
    if (!music || !self.downloadingArray || !self.sessionManager.downloadTasks)
        return;
    for (DownloadingItem *item in self.downloadingArray) {
        if (item.music == music) {
            for (NSURLSessionDownloadTask *task in self.sessionManager.downloadTasks) {
                if (task.taskIdentifier == item.downloadTaskId) {
                    [task cancel];
                    break;
                }
            }
        }
    }
}

- (void)addProgressReportBlock:(void (^)(NSProgress * _Nonnull, MusicItem * _Nonnull))block {
    if (block) {
        [self.progressReportBlockTable addObject:block];
    }
}

- (void)addFinishedHandlerBlock:(void (^)(MusicItem * _Nonnull))block {
    if (block) {
        [self.finishedHandlerBlockTable addObject:block];
    }
}

- (void)p_setMusicUrl:(MusicItem *)music andDispatchGroup:(dispatch_group_t)group {
    if (!music.songMid || !music.mediaMid) {
        music.musicUrl = nil;
        dispatch_group_leave(group);
        return;
    }
    
    //没有musicUrl时
    if (!music.musicUrl) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *url = [NSString stringWithFormat:VKeyAPI, music.songMid, music.mediaMid];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSData *data = (NSData *)responseObject;
            BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
            if (data.length == 0 || isSpace) {
                NSLog(@"error");
                dispatch_group_leave(group);
                return;
            }
            
            NSError *serializationError = nil;
            id resp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&serializationError];
            
            if (!resp) {
                NSLog(@"error");
                dispatch_group_leave(group);
                return;
            }
            
            NSString *vkey = resp[@"data"][@"items"][0][@"vkey"];
            if (!vkey) {
                music.musicUrl = nil;
                dispatch_group_leave(group);
                return;
            }
            music.musicUrl = [NSString stringWithFormat:musicUrlAPI, music.mediaMid, vkey];
            NSLog(@"[DownloadManager setMusicUrl:andDispatchGroup:]: set musicUrl END.");
            dispatch_group_leave(group);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error:\n%@", error.localizedDescription);
            music.musicUrl = nil;
            dispatch_group_leave(group);
        }];
        NSLog(@"[DownloadManager setMusicUrl:andDispatchGroup:]: END.");
    }
    else {
        dispatch_group_leave(group);
    }
}


@end
