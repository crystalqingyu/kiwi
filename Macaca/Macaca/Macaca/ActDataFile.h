//
//  ActDataFile.h
//  Macaca
//
//  Created by Julie on 15/3/17.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActDataFile : NSObject

@property (nonatomic, copy) NSString* dateStr; // 需要操作的文件名以及日期，如2015-03-17
@property (nonatomic, strong) NSMutableArray* actData; // 一天的运动数据

@property (nonatomic, strong) NSDictionary* actRecord; // 单条运动记录

- (NSString*)getFilePath;

- (void)addWithActRecord; // 增加单条记录

- (void)saveWithActData; // 保存某一天的记录

- (void)changeWithFirstTimeStr: (NSString*)firstTimeStr endTimeStr: (NSString*)endTimeStr indexNo: (int)index; // 修改单条记录的起始时间

- (void)removeWithIndexNo: (int)index; // 删除单条记录

- (NSString*)copyFileWithNewType: (NSString*)newType;

@end
