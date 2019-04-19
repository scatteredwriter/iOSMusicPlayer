//
//  PlayListDAO.m
//  MusicPlayer
//
//  Created by rod on 4/18/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "PlayListDAO.h"
#import <sqlite3.h>

#define DB_FILE_NAME @"MusicPlayer.sqlite3"

static PlayListDAO *_sharedPlayListDAO;

@interface PlayListDAO ()
@property (nonatomic, copy) NSString *dbFilePath;
@end

@implementation PlayListDAO
{
    sqlite3 *db;
}

+ (PlayListDAO *)sharedPlayListDAO {
    if (!_sharedPlayListDAO) {
        _sharedPlayListDAO = [[PlayListDAO alloc] init];
    }
    return _sharedPlayListDAO;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initDBFile];
        [self p_createMusicTable];
    }
    return self;
}

- (void)initDBFile {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.dbFilePath = [documentPath stringByAppendingPathComponent:DB_FILE_NAME];
}

- (void)p_createMusicTable {
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *create_music_table_sql = "CREATE TABLE IF NOT EXISTS Music (\
        songMid TEXT PRIMARY KEY,\
        songName TEXT,\
        singerName TEXT,\
        albumName TEXT,\
        albumImgUrl TEXT,\
        albumLargeImgUrl TEXT,\
        mediaMid TEXT,\
        albumMid TEXT);";
        if (sqlite3_exec(db, create_music_table_sql, NULL, NULL, NULL) == SQLITE_OK) {
            NSLog(@"[PlayListDAO p_createMusicTable]: CREATE TABLE Music SUCCESSFULLY OR TABLE Music EXISTS.");
        }
        else {
            NSLog(@"[PlayListDAO p_createMusicTable]: CREATE TABLE Music FAILED!");
            _hasProblem = YES;
        }
    }
    else {
        NSLog(@"[PlayListDAO p_createMusicTable]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
    }
    sqlite3_close(db);
}

- (MusicItem *)getMusicBysongMid:(NSString *)songMid {
    if (_hasProblem || !songMid || !songMid.length)
        return nil;
    
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *select_music_sql = "SELECT * FROM Music WHERE songMid=?";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, select_music_sql, -1, &statement, NULL) == SQLITE_OK) {
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
                NSLog(@"[PlayListDAO getMusicBysongMid]: GET MUSIC(songMid: %@, songName: %@).", music.songMid, music.songName);
                sqlite3_finalize(statement);
                sqlite3_close(db);
                return music;
            }
            else {
                NSLog(@"[PlayListDAO getMusicBysongMid]: NOT GET MUSIC(songMid: %@).", songMid);
            }
        }
        else {
            NSLog(@"[PlayListDAO getMusicBysongMid]: PREPARE SQL FAILED!");
            _hasProblem = YES;
        }
    }
    else {
        NSLog(@"[PlayListDAO getMusicBysongMid]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
    }
    sqlite3_close(db);
    return nil;
}

- (NSArray *)getAllMusics {
    if (_hasProblem)
        return nil;
    
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *select_musics_sql = "SELECT * FROM Music";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, select_musics_sql, -1, &statement, NULL) == SQLITE_OK) {
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
                
                [array insertObject:music atIndex:0];
            }
            sqlite3_finalize(statement);
            sqlite3_close(db);
            return array;
        }
        else {
            NSLog(@"[PlayListDAO getAllMusics]: PREPARE SQL FAILED!");
            _hasProblem = YES;
        }
    }
    else {
        NSLog(@"[PlayListDAO getAllMusics]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
    }
    sqlite3_close(db);
    return nil;
}

- (int)addMusic:(MusicItem *)music {
    if (_hasProblem || !music || !music.songMid || !music.mediaMid)
        return -1;
    
    // 判断数据库里是否含有该记录
    if ([self getMusicBysongMid:music.songMid]) {
        NSLog(@"[PlayListDAO addMusic]: MUSIC(songMid: %@) WAS IN DB.", music.songMid);
        return 0;
    }
    
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *insert_music_sql = "INSERT OR REPLACE INTO Music VALUES(?,?,?,?,?,?,?,?)";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, insert_music_sql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [music.songMid UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [music.songName UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 3, [music.singerName UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 4, [music.albumName UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 5, [music.albumImgUrl UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 6, [music.albumLargeImgUrl UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 7, [music.mediaMid UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 8, [music.albumMid UTF8String], -1, NULL);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"[PlayListDAO addMusic]: INSERT MUSIC(songMid: %@, songName: %@) FAILED!", music.songMid, music.songName);
                sqlite3_finalize(statement);
                sqlite3_close(db);
                return -1;
            }
            else {
                NSLog(@"[PlayListDAO addMusic]: INSERT MUSIC(songMid: %@, songName: %@) SUCCESSFULLY.", music.songMid, music.songName);
            }
        }
        else {
            NSLog(@"[PlayListDAO addMusic]: PREPARE SQL FAILED!");
            _hasProblem = YES;
            sqlite3_finalize(statement);
            sqlite3_close(db);
            return -1;
        }
        sqlite3_finalize(statement);
    }
    else {
        NSLog(@"[PlayListDAO addMusic]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
        sqlite3_close(db);
        return -1;
    }
    sqlite3_close(db);
    return 0;
}

- (int)removeMusicBysongMid:(NSString *)songMid {
    if (_hasProblem || !songMid || !songMid.length)
        return -1;
    
    const char *db_path = [self.dbFilePath UTF8String];
    if (sqlite3_open(db_path, &db) == SQLITE_OK) {
        const char *delete_music_sql = "DELETE FROM Music WHERE songMid=?";
        sqlite3_stmt *statement;
        
        if (sqlite3_prepare_v2(db, delete_music_sql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [songMid UTF8String], -1, NULL);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"[PlayListDAO removeMusicBysongMid:]: DELETE MUSIC(songMid: %@) FAILED!", songMid);
                sqlite3_finalize(statement);
                sqlite3_close(db);
                return -1;
            }
            else {
                NSLog(@"[PlayListDAO removeMusicBysongMid:]: DELETE MUSIC(songMid: %@) SUCCESSFULLY!", songMid);
            }
        }
        else {
            NSLog(@"[PlayListDAO removeMusicBysongMid:]: PREPARE SQL FAILED!");
            _hasProblem = YES;
            sqlite3_finalize(statement);
            sqlite3_close(db);
            return -1;
        }
        sqlite3_finalize(statement);
    }
    else {
        NSLog(@"[PlayListDAO removeMusicBysongMid:]: SQLITE OPEN FAILED!");
        _hasProblem = YES;
        sqlite3_close(db);
        return -1;
    }
    sqlite3_close(db);
    return 0;
}

@end
