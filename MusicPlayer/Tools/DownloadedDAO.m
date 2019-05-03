//
//  DownloadedDAO.m
//  MusicPlayer
//
//  Created by rod on 4/22/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "DownloadedDAO.h"
#import "DownloadManager.h"
#import <sqlite3.h>

#define DB_FILE_NAME @"MusicPlayer.sqlite3"

static DownloadedDAO *_sharedDownloadedDAO;

@interface DownloadedDAO ()
@property (nonatomic, copy) NSString *dbFilePath;
@end

@implementation DownloadedDAO
{
    sqlite3 *db;
}

+ (DownloadedDAO *)sharedDownloadedDAO {
    if (!_sharedDownloadedDAO) {
        _sharedDownloadedDAO = [[DownloadedDAO alloc] init];
    }
    return _sharedDownloadedDAO;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initDBFile];
        [self p_createDownloadedTable];
    }
    return self;
}

- (void)initDBFile {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.dbFilePath = [documentPath stringByAppendingPathComponent:DB_FILE_NAME];
}

- (void)p_createDownloadedTable {
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *create_downloaded_music_table_sql = "CREATE TABLE IF NOT EXISTS DownloadedMusic (\
        songMid TEXT PRIMARY KEY,\
        songName TEXT,\
        singerName TEXT,\
        albumName TEXT,\
        albumImgUrl TEXT,\
        albumLargeImgUrl TEXT,\
        mediaMid TEXT,\
        albumMid TEXT,\
        songId INTEGER);";
        if (sqlite3_exec(db, create_downloaded_music_table_sql, NULL, NULL, NULL) == SQLITE_OK) {
            NSLog(@"[DownloadedDAO p_createDownloadedTable]: CREATE TABLE DownloadedMusic SUCCESSFULLY OR TABLE DownloadedMusic EXISTS.");
        }
        else {
            NSLog(@"[DownloadedDAO p_createDownloadedTable]: CREATE TABLE DownloadedMusic FAILED!");
            _hasProblem = YES;
        }
    }
    else {
        NSLog(@"[DownloadedDAO p_createDownloadedTable]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
    }
    sqlite3_close(db);
}

- (MusicItem *)getDownloadedBysongMid:(NSString *)songMid {
    if (_hasProblem || !songMid || !songMid.length)
        return nil;
    
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *select_downloaded_music_sql = "SELECT * FROM DownloadedMusic WHERE songMid=?";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, select_downloaded_music_sql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [songMid UTF8String], -1, NULL);
            if (sqlite3_step(statement) == SQLITE_ROW) {
                MusicItem *music = [[MusicItem alloc] init];
                music.songMid = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                music.songName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                music.singerName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                music.albumName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                music.albumImgUrl = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                music.albumLargeImgUrl = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
                music.mediaMid = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                music.albumMid = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 7)];
                music.songId = sqlite3_column_int64(statement, 8);
                music.musicUrl = [[DownloadManager sharedDownloadManager] getMusicBymediaMid:music.mediaMid];
                music.isLocalFile = YES;
                NSLog(@"[DownloadedDAO getDownloadedBysongMid]: GET DOWNLOADED_MUSIC(songMid: %@, songName: %@, url: %@).", music.songMid, music.songName, music.musicUrl);
                sqlite3_finalize(statement);
                sqlite3_close(db);
                return music;
            }
            else {
//                NSLog(@"[DownloadedDAO getDownloadedBysongMid]: NOT GET DOWNLOADED_MUSIC(songMid: %@).", songMid);
            }
        }
        else {
            NSLog(@"[DownloadedDAO getDownloadedBysongMid]: PREPARE SQL FAILED!");
            _hasProblem = YES;
        }
    }
    else {
        NSLog(@"[DownloadedDAO getDownloadedBysongMid]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
    }
    sqlite3_close(db);
    return nil;
}

- (NSArray *)getAllDownloadeds {
    if (_hasProblem)
        return nil;
    
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *select_downloaded_musics_sql = "SELECT * FROM DownloadedMusic";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, select_downloaded_musics_sql, -1, &statement, NULL) == SQLITE_OK) {
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:10];
            while (sqlite3_step(statement) == SQLITE_ROW) {
                MusicItem *music = [[MusicItem alloc] init];
                music.songMid = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                music.songName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];
                music.singerName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                music.albumName = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 3)];
                music.albumImgUrl = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 4)];
                music.albumLargeImgUrl = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 5)];
                music.mediaMid = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 6)];
                music.albumMid = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 7)];
                music.songId = sqlite3_column_int64(statement, 8);
                music.musicUrl = [[DownloadManager sharedDownloadManager] getMusicBymediaMid:music.mediaMid];
                music.isLocalFile = YES;
                
                [array addObject:music];
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
            return array;
        }
        else {
            NSLog(@"[DownloadedDAO getAllDownloadeds]: PREPARE SQL FAILED!");
        }
    }
    else {
        NSLog(@"[DownloadedDAO getAllDownloadeds]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
    }
    sqlite3_close(db);
    return nil;
}

- (long)count {
    if (_hasProblem)
        return -1;
    
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *select_count_of_downloaded_musics_sql = "SELECT COUNT(*) FROM DownloadedMusic";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, select_count_of_downloaded_musics_sql, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                long count = sqlite3_column_int64(statement, 0);
                NSLog(@"[DownloadedDAO count]: COUNT OF TABLE DownloadedMusic IS %ld.", count);
                sqlite3_finalize(statement);
                sqlite3_close(db);
                return count;
            }
            else {
                NSLog(@"[DownloadedDAO count]: NOT GET COUNT OF TABLE DownloadedMusic!");
            }
        }
        else {
            NSLog(@"[DownloadedDAO count]: PREPARE SQL FAILED!");
        }
        sqlite3_finalize(statement);
    }
    else {
        NSLog(@"[DownloadedDAO count]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
    }
    sqlite3_close(db);
    return -1;
}

- (int)addDownloaded:(MusicItem *)music {
    if (_hasProblem || !music || !music.songMid)
        return -1;
    
    // 判断数据库里是否含有该记录
    if ([self getDownloadedBysongMid:music.songMid]) {
        NSLog(@"[DownloadedDAO addDownloaded]: DOWNLOADED_MUSIC(songMid: %@) WAS IN DB.", music.songMid);
        return 0;
    }
    
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *insert_downloaded_music_sql = "INSERT OR REPLACE INTO DownloadedMusic VALUES(?,?,?,?,?,?,?,?,?)";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, insert_downloaded_music_sql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [music.songMid UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [music.songName UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 3, [music.singerName UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 4, [music.albumName UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 5, [music.albumImgUrl UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 6, [music.albumLargeImgUrl UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 7, [music.mediaMid UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 8, [music.albumMid UTF8String], -1, NULL);
            sqlite3_bind_int64(statement, 9, music.songId);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"[DownloadedDAO addDownloaded]: INSERT DOWNLOADED_MUSIC(songMid: %@, songName: %@) FAILED!", music.songMid, music.songName);
                sqlite3_finalize(statement);
                sqlite3_close(db);
                return -1;
            }
            else {
                NSLog(@"[DownloadedDAO addDownloaded]: INSERT DOWNLOADED_MUSIC(songMid: %@, songName: %@) SUCCESSFULLY.", music.songMid, music.songName);
            }
        }
        else {
            NSLog(@"[DownloadedDAO addDownloaded]: PREPARE SQL FAILED!");
            sqlite3_finalize(statement);
            sqlite3_close(db);
            return -1;
        }
        sqlite3_finalize(statement);
    }
    else {
        NSLog(@"[DownloadedDAO addDownloaded]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
        sqlite3_close(db);
        return -1;
    }
    sqlite3_close(db);
    return 0;
}

- (int)removeDownloadedBysongMid:(NSString *)songMid {
    if (_hasProblem || !songMid || !songMid.length)
        return -1;
    
    MusicItem *music = [self getDownloadedBysongMid:songMid];
    if (!music) {
        return -1;
    }
    NSString *musicUrl = music.musicUrl;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:musicUrl]) {
        NSLog(@"[DownloadedDAO removeDownloadedBysongMid:]: FILE %@ DON'T EXIST!", musicUrl);
        return -1;
    }
    if ([fileManager removeItemAtPath:musicUrl error:nil]) {
        NSLog(@"[DownloadedDAO removeDownloadedBysongMid:]: DELETE FILE %@ SUCCESSFULLY!", musicUrl);
    }
    else {
        NSLog(@"[DownloadedDAO removeDownloadedBysongMid:]: DELETE FILE %@ FAILED!", musicUrl);
        return -1;
    }
    
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *delete_downloaded_music_sql = "DELETE FROM DownloadedMusic WHERE songMid=?";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, delete_downloaded_music_sql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [songMid UTF8String], -1, NULL);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"[DownloadedDAO removeDownloadedBysongMid:]: DELETE DOWNLOADED_MUSIC(songMid: %@) FAILED!", songMid);
                sqlite3_finalize(statement);
                sqlite3_close(db);
                return -1;
            }
            else {
                NSLog(@"[DownloadedDAO removeDownloadedBysongMid:]: DELETE DOWNLOADED_MUSIC(songMid: %@) SUCCESSFULLY!", songMid);
            }
        }
        else {
            NSLog(@"[DownloadedDAO removeDownloadedBysongMid:]: PREPARE SQL FAILED!");
            sqlite3_finalize(statement);
            sqlite3_close(db);
            return -1;
        }
        sqlite3_finalize(statement);
    }
    else {
        NSLog(@"[DownloadedDAO removeDownloadedBysongMid:]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
        sqlite3_close(db);
        return -1;
    }
    sqlite3_close(db);
    return 0;
}

@end
