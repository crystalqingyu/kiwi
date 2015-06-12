//
//  ActDataFile.m
//  Macaca
//
//  Created by Julie on 15/3/17.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "ActDataFile.h"

@implementation ActDataFile

- (NSString*)getFilePath {
    // 路径
    NSString* home = NSHomeDirectory();
    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *monthStr = [self.dateStr substringToIndex:7];
    NSString* filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",monthStr]];
    return filePath;
}

- (void)addWithActRecord {
    // 路径
    NSString* filePath = [self getFilePath];
    NSDictionary* dict = [NSDictionary dictionary];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* dayStr = [self.dateStr substringFromIndex:8];
    if([fileManager fileExistsAtPath:filePath]) { // 文件存在
        // 取出文件
        dict = [[NSDictionary dictionaryWithContentsOfFile:filePath] mutableCopy];
        if ([dict objectForKey:dayStr]) {// 日期已经存在
            // 添加记录
            NSMutableArray* mutableArray = [[dict objectForKey:dayStr] mutableCopy];
            [mutableArray addObject:self.actRecord];
            [dict setValue:mutableArray forKey:dayStr];
        } else {// 日期不存在
            [dict setValue:@[self.actRecord] forKey:dayStr];
        }
    }  else {// 文件不存在
        dict = [NSDictionary dictionaryWithObjectsAndKeys:@[self.actRecord],dayStr,nil];
    }
    // 写入文件
    [dict writeToFile:filePath atomically:YES];
}

- (void) saveWithActData {
    NSString* filePath = [self getFilePath];
    NSDictionary* dict = [NSDictionary dictionary];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* dayStr = [self.dateStr substringFromIndex:8];
    if([fileManager fileExistsAtPath:filePath]) { // 文件存在
        // 取出文件
        dict = [[NSDictionary dictionaryWithContentsOfFile:filePath] mutableCopy];
        // 添加记录
        [dict setValue:self.actData forKey:dayStr];
    }  else {// 文件不存在
        dict = [NSDictionary dictionaryWithObjectsAndKeys:self.actData,dayStr,nil];
    }
    // 写入文件
    [dict writeToFile:filePath atomically:YES];
}

- (void) changeWithFirstTimeStr:(NSString *)firstTimeStr endTimeStr:(NSString *)endTimeStr indexNo:(int)index {
    // 将修改数据存储文件中
    NSString* filePath = [self getFilePath];
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableArray* array = [dict valueForKey:[self.dateStr substringFromIndex:8]];
    NSMutableDictionary* dictWillChange = [array objectAtIndex:index];
    [dictWillChange setValue:firstTimeStr forKey:@"firstTimeStr"];
    [dictWillChange setValue:endTimeStr forKey:@"endTimeStr"];
    [dict setValue:array forKey:[self.dateStr substringFromIndex:8]];
    // 写入文件
    [dict writeToFile:filePath atomically:YES];
}

- (void)removeWithIndexNo:(int)index {
    NSString* filePath = [self getFilePath];
    // 字典中key
    NSString* day = [NSString stringWithFormat:@"%@",[self.dateStr substringFromIndex:8]];
    // 删除相应记录，保存文件
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableArray* array = [dict valueForKey:day];
    [array removeObjectAtIndex:index];
    [dict setValue:array forKey:day];
    [dict writeToFile:filePath atomically:YES];
}

@end
