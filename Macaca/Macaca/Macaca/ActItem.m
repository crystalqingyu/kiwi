//
//  ActItem.m
//  Macaca
//
//  Created by Julie on 14/12/17.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "ActItem.h"

@interface ActItem () <NSCoding>

@end

@implementation ActItem

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject: _firstTimeStr forKey: @"firstTime"];
    [aCoder encodeObject:_endTimeStr forKey: @"endTime"];
    [aCoder encodeObject:_name forKey:@"name"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _firstTimeStr = [aDecoder decodeObjectForKey:@"firstTime"];
        _endTimeStr = [aDecoder decodeObjectForKey:@"endTime"];
    }
    return self;
}

@end
