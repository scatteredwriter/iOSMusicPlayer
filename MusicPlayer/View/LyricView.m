//
//  LyricView.m
//  MusicPlayer
//
//  Created by rod on 4/20/19.
//  Copyright © 2019 RodChong. All rights reserved.
//

#import "LyricView.h"
#import "RCHTTPSessionManager.h"
#import "QQMusicAPI.h"
#import "MusicItem.h"
#import "DownloadManager.h"

@interface LyricView ()
@property (nonatomic, copy) NSString *lyric;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation LyricView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textView = [[UITextView alloc] init];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.editable = NO;
        self.textView.textContainerInset = UIEdgeInsetsZero;
        [self addSubview:self.textView];
    }
    return self;
}

- (void)setMusic:(MusicItem *)music {
    _music = music;
    if (music.isLocalFile) {
        [self p_getLocalLyricFile];
    }
    else {
        [self p_getResp];
    }
}

- (void)p_getLocalLyricFile {
    self.lyric = [[DownloadManager sharedDownloadManager] getLyricBysongMid:self.music.songMid];
    if (!self.lyric) {
        NSLog(@"[LyricView p_getLyricFromFile]: LYRIC FILE READ FAILED! TRY GET LYRIC ONLINE.");
        [self p_getResp];
        return;
    }
    [self p_initLyric];
}

- (void)p_getResp {
    if (!self.music)
        return;
    RCHTTPSessionManager *manager = [RCHTTPSessionManager getRCHTTPSessionManager];
    NSString *url = [NSString stringWithFormat:lyricAPI, self.music.songId];
    NSDictionary *header = @{
                             @"Referer":[NSString stringWithFormat:@"https://y.qq.com/n/yqq/song/%@.html", self.music.songMid]
                             };
    [manager GET:url parameters:nil headers:header progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (!responseObject)
            return;

        NSString *base64_lyric = responseObject[@"lyric"];
        NSData *data = [[NSData alloc] initWithBase64EncodedString:base64_lyric options:NSDataBase64DecodingIgnoreUnknownCharacters];
        self.lyric = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self p_initLyric];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error\n%@", error.localizedDescription);
    }];
}

- (void)p_initLyric {
    if (!self.lyric)
        return;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.*\\]" options:NSRegularExpressionUseUnixLineSeparators error:&error];
    self.lyric = [regex stringByReplacingMatchesInString:self.lyric options:NSMatchingReportProgress range:NSMakeRange(0, self.lyric.length) withTemplate:@""];
    self.lyric = [self.lyric stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:18];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    self.textView.text = @"";
    [self.textView scrollRangeToVisible:NSMakeRange(0, 0)];
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:self.lyric attributes:@{ NSParagraphStyleAttributeName:paragraphStyle,
        NSForegroundColorAttributeName:[UIColor whiteColor],
        NSFontAttributeName:[UIFont systemFontOfSize:18]}];
    [self.textView scrollRangeToVisible:NSMakeRange(0, self.textView.text.length ? 1 : 0)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textView.frame = CGRectMake(15, 0, CGRectGetWidth(self.frame) - 15 * 2, CGRectGetHeight(self.frame));
}

- (void)clearLyric {
    self.lyric = @"";
    [self p_initLyric];
}

@end
