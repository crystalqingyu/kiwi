//
//  AboutViewController.m
//  Macaca
//
//  Created by Julie on 14/12/12.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "AboutViewController.h"
#import "GroupSetting.h"
#import "SettingItem.h"
#import "ArrowSettingItem.h"
#import <MessageUI/MessageUI.h>
#import "VersionIntroductionViewController.h"

@interface AboutViewController () <MFMailComposeViewControllerDelegate>

// 客服电话需要
@property (nonatomic, strong) UIWebView* webView;

@end

@implementation AboutViewController

// 手动隐藏tabbar，注意要再init中实现
- (instancetype)init {
    if ([super init]) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"关于猕猴桃"];
    [self setUpGroup0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpGroup0 {
    SettingItem* item0 = [ArrowSettingItem settingItemWithIcon:@"" text:@"联系我们" detailText:@"vajaspine@163.com"];
    NSString* mailStr = item0.detailText;
    item0.option = ^{
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        NSString* title;
        if (!mailClass) {
            title = @"当前系统版本不支持应用内发送邮件";
        } else if (![mailClass canSendMail]) {
            title = @"没有设置邮件账户";
        } else {
            [self displayMailPicker:mailStr];
            return;
        }
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
    };
    
    SettingItem* item1 = [ArrowSettingItem settingItemWithIcon:@"" text:@"功能介绍" desClass:[VersionIntroductionViewController class]];
    item1.detailText = @"2.0版本新增功能";

    GroupSetting* group = [[GroupSetting alloc] init];
//    group.footer = @"敬请期待";
//    group.title = @"根据个人情况与喜好设置";
    group.settingGroup = @[item0, item1];
    [self.data addObject:group];
}

// 调出邮件发送窗口
- (void)displayMailPicker: (NSString*)mailStr {
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    // 设置代理
    __weak typeof(self) shareVc = self;
    mailPicker.mailComposeDelegate = shareVc;
    // 设置主题
    [mailPicker setSubject: @"eMail主题"];
    // 添加收件人
    NSArray *toRecipients = [NSArray arrayWithObject: mailStr];
    [mailPicker setToRecipients: toRecipients];
//    // 添加抄送
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
//    [mailPicker setCcRecipients:ccRecipients];
//    // 添加密送
//    NSArray *bccRecipients = [NSArray arrayWithObjects:@"fourth@example.com", nil];
//    [mailPicker setBccRecipients:bccRecipients];
    
//    // 添加一张图片
//    UIImage *addPic = [UIImage imageNamed: @"Icon@2x.png"];
//    NSData *imageData = UIImagePNGRepresentation(addPic);            // png
//    // 关于mimeType：http://www.iana.org/assignments/media-types/index.html
//    [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"Icon.png"];
    
//    // 添加一个pdf附件
//    NSString *file = [self fullBundlePathFromRelativePath:@"高质量C++编程指南.pdf"];
//    NSData *pdf = [NSData dataWithContentsOfFile:file];
//    [mailPicker addAttachmentData: pdf mimeType: @"" fileName: @"高质量C++编程指南.pdf"];
    
    NSString *emailBody = @"<font color='red'>eMail</font> 正文";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];
}

#pragma mark - 实现 MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // 关闭邮件发送窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"已取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"已成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"邮件已发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"邮件发送失败";
            break;
        default:
            msg = @"";
            break;
    }
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alter show];
}

// 设置header图片，覆盖前面的titleForHeader
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImageView* header = [[UIImageView alloc] init];
    header.image = [UIImage imageNamed:@"header-image-kiwi"];
    return header;
}
// 设置header的高度，一定要有，否则没有header图片显示！！！
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.view.frame.size.width/2;
}

@end
