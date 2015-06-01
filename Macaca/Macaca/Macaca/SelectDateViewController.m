//
//  SelectDateViewController.m
//  Macaca
//
//  Created by ZhangQi on 15/4/2.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "SelectDateViewController.h"

@interface SelectDateViewController ()
@property (weak, nonatomic) IBOutlet UIView *blankView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
- (IBAction)commitDate:(UIButton *)sender;

@end

@implementation SelectDateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // 为空白view添加手势
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelSel:)];
    [self.blankView addGestureRecognizer:tapGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)commitDate:(UIButton *)sender {
    NSLog(@"commitDate, date=%@", self.datePicker.date);
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StatDateSelected" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.datePicker.date,@"selectedDate", nil]];
    
    // 将view移出
    [UIView animateWithDuration:0.75f animations:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    } completion:^(BOOL finished) {
    }];
}

- (void)cancelSel:(id)sender {
    [UIView animateWithDuration:0.75f animations:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    } completion:^(BOOL finished) {
    }];
}

@end
