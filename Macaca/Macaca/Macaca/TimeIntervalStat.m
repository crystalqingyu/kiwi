//
//  TimeIntervalCalories.m
//  Macaca
//
//  Created by ZhangQi on 15/4/2.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "TimeIntervalStat.h"

static const double GAUSSIAN_MIU_24HR = 630.0;
static const double GAUSSIAN_SIGMA_24HR = 270.0;
static const double STANDARD_WEIGHT = 48.0; // 标准体重
static const double gaussian_dist [] = {
    /* 0.00 ~ 0.09 */ 0.5000, 0.5040, 0.5080, 0.5120, 0.5160, 0.5199, 0.5239, 0.5279, 0.5319, 0.5359,
    /* 0.10 ~ 0.19 */ 0.5398, 0.5438, 0.5478, 0.5517, 0.5557, 0.5596, 0.5636, 0.5675, 0.5714, 0.5753,
    /* 0.20 ~ 0.29 */ 0.5793, 0.5832, 0.5871, 0.5910, 0.5948, 0.5987, 0.6026, 0.6064, 0.6103, 0.6141,
    /* 0.30 ~ 0.39 */ 0.6179, 0.6217, 0.6255, 0.6293, 0.6331, 0.6368, 0.6404, 0.6443, 0.6480, 0.6517,
    /* 0.40 ~ 0.49 */ 0.6554, 0.6591, 0.6628, 0.6664, 0.6700, 0.6736, 0.6772, 0.6808, 0.6844, 0.6879,
    /* 0.50 ~ 0.59 */ 0.6915, 0.6950, 0.6985, 0.7019, 0.7054, 0.7088, 0.7123, 0.7157, 0.7190, 0.7224,
    /* 0.60 ~ 0.69 */ 0.7257, 0.7291, 0.7324, 0.7357, 0.7389, 0.7422, 0.7454, 0.7486, 0.7517, 0.7549,
    /* 0.70 ~ 0.79 */ 0.7580, 0.7611, 0.7642, 0.7673, 0.7703, 0.7734, 0.7764, 0.7794, 0.7823, 0.7852,
    /* 0.80 ~ 0.89 */ 0.7881, 0.7910, 0.7939, 0.7967, 0.7995, 0.8023, 0.8051, 0.8078, 0.8106, 0.8133,
    /* 0.90 ~ 0.99 */ 0.8159, 0.8186, 0.8212, 0.8238, 0.8264, 0.8289, 0.8355, 0.8340, 0.8365, 0.8389,
    /* 1.00 ~ 1.09 */ 0.8413, 0.8438, 0.8461, 0.8485, 0.8508, 0.8531, 0.8554, 0.8577, 0.8599, 0.8621,
    /* 1.10 ~ 1.19 */ 0.8643, 0.8665, 0.8686, 0.8708, 0.8729, 0.8749, 0.8770, 0.8790, 0.8810, 0.8830,
    /* 1.20 ~ 1.29 */ 0.8849, 0.8869, 0.8888, 0.8907, 0.8925, 0.8944, 0.8962, 0.8980, 0.8997, 0.9015,
    /* 1.30 ~ 1.39 */ 0.9032, 0.9049, 0.9066, 0.9082, 0.9099, 0.9115, 0.9131, 0.9147, 0.9162, 0.9177,
    /* 1.40 ~ 1.49 */ 0.9192, 0.9207, 0.9222, 0.9236, 0.9251, 0.9265, 0.9279, 0.9292, 0.9306, 0.9319,
    /* 1.50 ~ 1.59 */ 0.9332, 0.9345, 0.9357, 0.9370, 0.9382, 0.9394, 0.9406, 0.9418, 0.9430, 0.9441,
    /* 1.60 ~ 1.69 */ 0.9452, 0.9463, 0.9474, 0.9484, 0.9495, 0.9505, 0.9515, 0.9525, 0.9535, 0.9535,
    /* 1.70 ~ 1.79 */ 0.9554, 0.9564, 0.9573, 0.9582, 0.9591, 0.9599, 0.9608, 0.9616, 0.9625, 0.9633,
    /* 1.80 ~ 1.89 */ 0.9641, 0.9648, 0.9656, 0.9664, 0.9672, 0.9678, 0.9686, 0.9693, 0.9700, 0.9706,
    /* 1.90 ~ 1.99 */ 0.9713, 0.9719, 0.9726, 0.9732, 0.9738, 0.9744, 0.9750, 0.9756, 0.9762, 0.9767,
    /* 2.00 ~ 2.09 */ 0.9772, 0.9778, 0.9783, 0.9788, 0.9793, 0.9798, 0.9803, 0.9808, 0.9812, 0.9817,
    /* 2.10 ~ 2.19 */ 0.9821, 0.9826, 0.9830, 0.9834, 0.9838, 0.9842, 0.9846, 0.9850, 0.9854, 0.9857,
    /* 2.20 ~ 2.29 */ 0.9861, 0.9864, 0.9868, 0.9871, 0.9874, 0.9878, 0.9881, 0.9884, 0.9887, 0.9890,
    /* 2.30 ~ 2.39 */ 0.9893, 0.9896, 0.9898, 0.9901, 0.9904, 0.9906, 0.9909, 0.9911, 0.9913, 0.9916,
    /* 2.40 ~ 2.49 */ 0.9918, 0.9920, 0.9922, 0.9925, 0.9927, 0.9929, 0.9931, 0.9932, 0.9934, 0.9936,
    /* 2.50 ~ 2.59 */ 0.9938, 0.9940, 0.9941, 0.9943, 0.9945, 0.9946, 0.9948, 0.9949, 0.9951, 0.9952,
    /* 2.60 ~ 2.69 */ 0.9953, 0.9955, 0.9956, 0.9957, 0.9959, 0.9960, 0.9961, 0.9962, 0.9963, 0.9964,
    /* 2.70 ~ 2.79 */ 0.9965, 0.9966, 0.9967, 0.9968, 0.9969, 0.9970, 0.9971, 0.9972, 0.9973, 0.9974,
    /* 2.80 ~ 2.89 */ 0.9974, 0.9975, 0.9976, 0.9977, 0.9977, 0.9978, 0.9979, 0.9979, 0.9980, 0.9981,
    /* 2.90 ~ 2.99 */ 0.9981, 0.9982, 0.9982, 0.9983, 0.9984, 0.9984, 0.9985, 0.9985, 0.9986, 0.9986,
    /* 3.00 ~ 3.90 */ 0.9987, 0.9990, 0.9993, 0.9995, 0.9997, 0.9998, 0.9998, 0.9999, 0.9999, 1.0000
};

@implementation TimeIntervalStat

- (NSMutableArray*) timeIntervalActArrayFrom: (NSDate*) start to: (NSDate*) end {
    // 日期格式
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDateFormatter* timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"HH:mm:ss"];
    
    // 开始日期、时间，结束日期、时间
    NSString* startDateStr = [dateFormat stringFromDate:start];
    NSString* startTimeStr = [timeFormat stringFromDate:start];
    NSString* endDateStr = [dateFormat stringFromDate:end];
    NSString* endTimeStr = [timeFormat stringFromDate:end];
    
    //NSLog(@"%@,%@,%@,%@",startDateStr,startTimeStr,endDateStr,endTimeStr);
    
    // 生成需要打开的文件路径
    NSString* home = NSHomeDirectory(); // 主目录路径
    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
    
    // 返回结构
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    
    //创建文件管理器
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    // 将记录添加进返回结构
    int i = 0;
    while (1) {
        NSDate* date = [NSDate dateWithTimeInterval:86400*i sinceDate:start];
        //NSLog(@"date=%@, end=%@",date,end);
        ++i;
        // 终止条件
        if ([date compare:end] == NSOrderedDescending) {
            break;
        }
        
        NSString* dateStr = [dateFormat stringFromDate:date];
        //NSLog(@"dateStr=%@",dateStr);
        // 活动记录文件的路径
        NSString* filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",[dateStr substringToIndex:7]]];
        //NSLog(@"file=%@",filePath);
        // 检查文件是否存在
        if (![fileManager fileExistsAtPath:filePath]) {
            continue;
        }
        // 字典中key
        NSString* day = [NSString stringWithFormat:@"%@",[dateStr substringFromIndex:8]];
        // 读取当天的记录
        NSMutableArray* arr = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:day];
        if (arr==nil) {
            continue;
        }
        
        //NSLog(@"arr=%@",arr);
        
        // 将结束时间在 start 后 且 开始时间在 end 前 的活动加入 ret
        if ([dateStr compare:startDateStr] == NSOrderedSame) {
            // case: date 与 start 为同一天
            for (NSMutableDictionary* dict in arr) {
                NSMutableDictionary* new_dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                if ([(NSString*)[dict objectForKey:@"firstTimeStr"] compare:startTimeStr] == NSOrderedDescending) {
                    // case: 开始时间在start之后的
                } else if ([(NSString*)[dict objectForKey:@"endTimeStr"] compare:startTimeStr] != NSOrderedDescending) {
                    // case: 结束时间在start之前的
                    continue;
                } else {
                    // case: 持续时间包含start的
                    [new_dict setValue:startTimeStr forKey:@"firstTimeStr"];
                }
                if (([dateStr compare:endDateStr] == NSOrderedSame) && ([(NSString*)[dict objectForKey:@"endTimeStr"] compare:endTimeStr] == NSOrderedDescending)) {
                    // case: 开始时间和结束时间是同一天，且运动结束时间晚于end
                    if ([(NSString*)[dict objectForKey:@"firstTimeStr"] compare:endTimeStr] != NSOrderedAscending) {
                        // case: 运动的开始时间晚于end, 跳出for循环
                        break;
                    }
                    [new_dict setObject:endTimeStr forKey:@"endTimeStr"];
                }
                [ret addObject:new_dict];
            }
        } else if ([dateStr compare:endDateStr] == NSOrderedSame) {
            for (NSDictionary* dict in arr) {
                if ([(NSString*)[dict objectForKey:@"endTimeStr"] compare:endTimeStr] == NSOrderedAscending) {
                    // case: 结束时间在end前的
                    [ret addObject:dict];
                } else if ([(NSString*)[dict objectForKey:@"firstTimeStr"] compare:endTimeStr] != NSOrderedAscending) {
                    // case: 开始时间在end后的
                    break;
                } else {
                    // case: 持续时间包含end的
                    NSMutableDictionary* new_dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                    [new_dict setValue:endTimeStr forKey:@"endTimeStr"];
                    [ret addObject:new_dict];
                }
            }
        } else {
            [ret addObjectsFromArray:arr];
        }
    }
    
    NSLog(@"timeIntervalActArray, ret=%@",ret);
    
    return ret;
}

- (double) minuteElapsedFrom:(NSString*) start to:(NSString*) end {
    int sec_minus = [[end substringWithRange:NSMakeRange(6, 2)] intValue] - [[start substringWithRange:NSMakeRange(6, 2)] intValue];
    int min_minus = [[end substringWithRange:NSMakeRange(3, 2)] intValue] - [[start substringWithRange:NSMakeRange(3, 2)] intValue];
    int hour_minus = [[end substringWithRange:NSMakeRange(0, 2)] intValue] - [[start substringWithRange:NSMakeRange(0, 2)] intValue];
    return (hour_minus * 3600 + min_minus * 60 + sec_minus)/60.0;
}

- (double)sumCalories:(NSMutableArray*) arr {
    double res = 0.0;

    for (int i=0; i<[arr count]; ++i) {
        double minute_elapsed = [self minuteElapsedFrom:[[arr objectAtIndex:i] objectForKey:@"firstTimeStr"]  to:[[arr objectAtIndex:i] objectForKey:@"endTimeStr"]];
        double calories_per_hour = [[[arr objectAtIndex:i] objectForKey:@"calorie"] doubleValue];
        
        res += minute_elapsed * calories_per_hour / 60.0;
    }
    
    return res;
}

- (double) timeIntervalCaloriesFrom: (NSDate*) start to: (NSDate*) end {
    return [self sumCalories:[self timeIntervalActArrayFrom:start to:end]];
}

- (double) rankInPast24Hour: (double) calorie {
    double nvalue = (calorie - GAUSSIAN_MIU_24HR) / GAUSSIAN_SIGMA_24HR;
    if (nvalue < 0.0) {
        return 1.0 - [self gaussianValue:-nvalue];
    } else {
        return [self gaussianValue:nvalue];
    }
}

- (double) gaussianValue: (double) x {
    if (x > 3.8) {
        return 0.9999;
    } else if (x >= 3.0) {
        return gaussian_dist[300 + (int)((x - 3.0) * 10)];
    } else {
        return gaussian_dist[(int)(x * 100)];
    }
}

- (double) rankInPast24Hour {
    return [self rankInPast24Hour:[self caloriesInPast24Hour]];
}

- (double) caloriesInPast24Hour {
    return [self timeIntervalCaloriesFrom:[NSDate dateWithTimeIntervalSinceNow:-86400] to:[NSDate date]];
}

@end
