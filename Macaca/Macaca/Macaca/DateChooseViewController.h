//
//  DateChooseViewController.h
//  Macaca
//
//  Created by Julie on 14/12/18.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateChooseViewControllerDelegate <NSObject>

- (void)didPopToActQueryViewController: (NSDate*)date;

@end

@interface DateChooseViewController : UIViewController

@property (nonatomic, retain) id <DateChooseViewControllerDelegate> delegate;

@property (nonatomic, strong) NSDate* chooseDate; // 传过来的文件日期

@end
