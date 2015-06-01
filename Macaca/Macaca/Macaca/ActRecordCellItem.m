//
//  ActRecordCellItem.m
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "ActRecordCellItem.h"

@implementation ActRecordCellItem

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.title = [dict objectForKey:@"title"];
        self.icon = [dict objectForKey:@"icon"];
        self.calorie = [dict objectForKey:@"calorie"];
    }
    return self;
}

+ (instancetype)actRecordCellItemWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}


@end
