//
//  FileDownload.m
//  文件下载
//
//  Created by liujingjing on 15/6/9.
//  Copyright (c) 2015年 liujingjing. All rights reserved.
//

#import "FileDownload.h"

#define kBytesPerTimes 20480
#define kTimeOut 10.0

@interface FileDownload ()

@property (nonatomic,strong) NSString* filePath;

@end

@implementation FileDownload

- (NSString*)filePath {
    if (!_filePath) {
        _filePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:_fileName];
        NSLog(@"%@",_filePath);
    }
    return _filePath;
}

- (void)downloadFileWithURL: (NSURL*)url {
    // 获取文件大小
    long long fileSize = [self fileSizeWithURL: url];
    // 判断是否下载;
    if ([self isDownLoadFileWithFileSize:fileSize]) {
        // 确定每个数据包的大小
        long long fromB = 0;
        long long toB = 0;
        while (fileSize>kBytesPerTimes) {
            toB = fromB + kBytesPerTimes-1;
            // 下载指定range 的文件
            [self downloadDataWithUrl:url fromB:fromB toB:toB];
            fileSize -= kBytesPerTimes;
            fromB += kBytesPerTimes;
        }
        toB = fromB + fileSize-1;
        // 下载指定range 的文件
        [self downloadDataWithUrl:url fromB:fromB toB:toB];
    }
}

// 下载指定range的文件
- (void)downloadDataWithUrl: (NSURL*)url fromB: (long long)fromB toB: (long long)toB {
    // 网络请求
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kTimeOut];
    // 设置range
    NSString* range = [NSString stringWithFormat:@"bytes=%lld-%lld",fromB,toB];
    NSLog(@"%@",range);
    [request setValue:range forHTTPHeaderField:@"Range"];
    // 设置response
    NSURLResponse* response = nil;
    // 连接网络资源
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    // 追加写入文件
    [self writeToFilePath: data];
}

// 获取文件大小
- (long long)fileSizeWithURL: (NSURL*)url {
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kTimeOut];
    request.HTTPMethod = @"HEAD";
    NSURLResponse* response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    return response.expectedContentLength;
}

// 判断是否下载，避免重复追加下载
- (BOOL)isDownLoadFileWithFileSize: (long long)fileSize {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        if ([[[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL][NSFileSize] longLongValue]==fileSize) {
            return NO;
        } else {
            return YES;
        }
    } else {
        return YES;
    }
}

- (void)writeToFilePath: (NSData*)data {
    // 打开缓存文件
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    // 文件不存在创建文件
    if (!fileHandle) {
        [data writeToFile:self.filePath atomically:YES];
    } else {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        [fileHandle closeFile];
    }
}
@end
