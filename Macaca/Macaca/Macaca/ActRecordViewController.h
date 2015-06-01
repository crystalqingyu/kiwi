//
//  ActRecordViewController.h
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class ActRecordCellItem,GeneralAction;

@interface ActRecordViewController : UICollectionViewController

//@property (nonatomic, weak) UICollectionView* collectionView;
@property (strong, nonatomic) IBOutlet UILabel *titleLable;
@property (strong, nonatomic) IBOutlet UILabel *timeLable;
@property (strong, nonatomic) IBOutlet UILabel *calorieLable;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
- (IBAction)cancelBtn:(UIButton *)sender;
- (IBAction)jumpToActFull;
- (IBAction)jumpToShare:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UIView *currentStateView;

@property (nonatomic, strong) NSDate* startDate; // 计时开始时间
@property (nonatomic, strong) NSDate* pauseDate; // 计时暂停时间
@property (nonatomic, retain) NSTimer* timer;

@property (strong, nonatomic) ActRecordCellItem* currentAct; // 当前运动
@property (strong, nonatomic) ActRecordCellItem* lastAct; // 上一个运动

@property (assign, nonatomic) double weight; // 体重，便于计算热量

@property (strong, nonatomic) GeneralAction* generalAction; //通用功能类

@property (nonatomic, strong) NSMutableArray* data;

@property (nonatomic, assign) SystemSoundID* btnSound;

@end
