//
//  ShareViewController.m
//  Macaca
//
//  Created by Julie on 15/3/26.
//  Copyright (c) 2015年 _VAJASPINE_. All rights reserved.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.weixinDelegate = [UIApplication sharedApplication].delegate;
    self.weiboDelegate = [UIApplication sharedApplication].delegate;
    self.qqKongjianDelegate = [UIApplication sharedApplication].delegate;
    // 添加手势
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionBackToActRecordView:)];
    [self.blankView addGestureRecognizer:tapGesture];
    // 按钮变圆
    [self setBtnRound];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionBackToActRecordView:(id)sender {
    [self backToActRecordView];
}

- (void)setBtnRound {
    // 朋友圈
    self.pengyouquanBtn.layer.cornerRadius = self.pengyouquanBtn.frame.size.width/2;
    self.pengyouquanBtn.layer.masksToBounds = YES;
    // 微信
    self.weixinBtn.layer.cornerRadius = self.weixinBtn.frame.size.width/2;
    self.weixinBtn.layer.masksToBounds = YES;
    // 微博
    self.weiboBtn.layer.cornerRadius = self.weiboBtn.frame.size.width/2;
    self.weiboBtn.layer.masksToBounds = YES;
    // 朋友圈
    self.qqkongjianBtn.layer.cornerRadius = self.qqkongjianBtn.frame.size.width/2;
    self.qqkongjianBtn.layer.masksToBounds = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)shareWeixinFriends {
    [_weixinDelegate changeScene:WXSceneSession];
    [_weixinDelegate sendByWeixin];
}

- (IBAction)shareWeixinFriendsCircle {
    [_weixinDelegate changeScene:WXSceneTimeline];
    [_weixinDelegate sendByWeixin];
}

- (IBAction)shareWeibo {
    [_weiboDelegate sendByWeibo];
}

- (IBAction)shareQQKongjian {
    [_qqKongjianDelegate sendByQQKongjian];
}

- (IBAction)backToActRecordView {
    [UIView animateWithDuration:0.75f animations:^{
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } completion:^(BOOL finished) {
        
    }];
}
@end
