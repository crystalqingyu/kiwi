//
//  UploadFile.h
//  Macaca
//
//  Created by liujingjing on 15/6/10.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadFile : NSObject

@property (nonatomic, copy) NSString* fileType;

- (void)uploadFileWithURL:(NSURL *)url data:(NSData *)data fileName: (NSString*)fileName;

@end
