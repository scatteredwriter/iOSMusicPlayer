//
//  QQMusicAPI.m
//  MusicPlayer
//
//  Created by rod on 4/10/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "QQMusicAPI.h"

NSString * const RankingAPI =  @"https://i.y.qq.com/v8/fcg-bin/fcg_v8_toplist_cp.fcg?tpl=20&page=detail&type=top&topid=%@&g_tk=5381&loginUin=0&hostUin=0&format=json&inCharset=utf8&outCharset=utf-8&notice=0&platform=yqq";
NSString * const musicUrlAPI = @"https://dl.stream.qqmusic.qq.com/%@.mp3?vkey=%@&guid=9391879250&fromtag=27";
NSString * const albumImgUrlAPI = @"https://y.gtimg.cn/music/photo_new/T002R300x300M000%@.jpg?max_age=2592000";
