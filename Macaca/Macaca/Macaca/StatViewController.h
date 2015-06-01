//
//  StatViewController.h
//  Macaca
//
//  Created by ZhangQi on 15/1/12.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface StatViewController : UIViewController<CPTPlotDataSource,CPTPieChartDelegate,UIScrollViewDelegate>

//饼图数组，每个扇形的value
@property(retain,nonatomic)NSMutableArray *arr;
//每个扇形的size(即每个扇形value的绝对值之和)
@property(retain,nonatomic)NSMutableArray *arrSize;
//饼图每个元素的value绝对值总和，
@property(assign,nonatomic)double arrSum;
//所有负数元素的value总和（<0）
@property(assign,nonatomic)double arrNegSum;
//保存所有运动的数据，未做<5%的merge
@property(retain,nonatomic)NSMutableArray *allActArr;

//显示时间or热量，0：时间，1：热量
@property(assign,nonatomic)int dataSel;

//时间段标识，0：日，1：周，2：月，3：年，-1：选择日期
@property(assign,nonatomic)int timeSel;

//画布
@property(retain,nonatomic)CPTXYGraph *graph;
//饼图
@property(retain,nonatomic)CPTPieChart *piePlot;
//是否显示图例
@property(assign,nonatomic)int displayLegend;

@end
