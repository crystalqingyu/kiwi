//
//  ActRecordCellItem.h
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActRecordCellItem : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* icon;
@property (nonatomic, copy) NSString* calorie;

- (instancetype)initWithDict: (NSDictionary*)dict;

+ (instancetype)actRecordCellItemWithDict: (NSDictionary*)dict;

@end
