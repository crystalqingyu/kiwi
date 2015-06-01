//
//  ActItem.h
//  Macaca
//  存储运动的名字、起始时间、终止时间模型
//  Created by Julie on 14/12/17.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActItem : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* firstTimeStr;
@property (nonatomic, copy) NSString* endTimeStr;

@end
