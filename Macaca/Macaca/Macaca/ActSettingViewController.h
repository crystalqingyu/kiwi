//
//  ActSettingViewController.h
//  Macaca
//
//  Created by Julie on 15/1/11.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActSettingViewController : UIViewController

@property (nonatomic, copy) NSString* sort; // 运动类别

@property (nonatomic, strong) NSDictionary* data;

@property (nonatomic, weak) NSString* currentAct; // 当前正在进行的运动

@end
