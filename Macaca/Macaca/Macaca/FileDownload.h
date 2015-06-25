//
//  FileDownload.h
//  文件下载
//
//  Created by liujingjing on 15/6/9.
//  Copyright (c) 2015年 liujingjing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownload : NSObject

// 存储的文件名字
@property (nonatomic,copy) NSString* fileName;

- (void)downloadFileWithURL: (NSURL*)url;

@end
