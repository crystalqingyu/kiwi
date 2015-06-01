//
//  TimeIntervalCalories.h
//  Macaca
//
//  Created by ZhangQi on 15/4/2.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeIntervalStat : NSObject

- (double) timeIntervalCaloriesFrom: (NSDate*) start to: (NSDate*) end;

- (double) rankInPast24Hour;
- (double) rankInPast24Hour: (double) calorie;

- (double) caloriesInPast24Hour;

@end
