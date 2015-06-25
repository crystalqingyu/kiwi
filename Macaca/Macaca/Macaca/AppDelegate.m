//
//  AppDelegate.m
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import "AppDelegate.h"
#import "ActRecordViewController.h"
#import "MaNavigationController.h"
#import "ShareViewController.h"
#import "TimeIntervalStat.h"
#import "UploadFile.h"
#import "ActDataFile.h"
#import "KeychainItemWrapper.h"
#import "FileDownload.h"

@interface AppDelegate () <shareByWeixinDelegate,shareByWeiboDelegate,shareByQQKongjianDelegate>

@property (nonatomic,strong) KeychainItemWrapper* wrapper;

@end

@implementation AppDelegate

- (id)init{
    if(self = [super init]){
        _scene = WXSceneSession;
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 注册微信、微博
    [WXApi registerApp:@"wxc45c86eba922df65"];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"2230181521"];
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1104452027" andDelegate:self];
    // 初始化一个保存用户帐号的KeychainItemWrapper
    _wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"kiwi"
                                                   accessGroup:nil];
    // 手机从没有安装过应用，通过keychain设置UUID（如果有直接取）
    if ([[_wrapper objectForKey:(__bridge id)kSecValueData] isEqualToString:@""]) {
        // 获取上传文件的文件夹名称idfv
        NSString* uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        //保存数据
        [_wrapper setObject:uuid forKey:(__bridge id)kSecValueData];
    }
    
    // 判断是否应该升级新版本
    NSURL* url = [NSURL URLWithString:@"http://itunes.apple.com/lookup?id=966621372"];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse* response, NSData* data, NSError* connectionError){
        // 判断连接有无错误
        if (connectionError==nil) {
            NSError* jsonError;
            NSDictionary* appInfoDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            // 判断序列化有无错误
            if (jsonError==nil) {
                NSArray* resultsArray = [appInfoDict objectForKey:@"results"];
                NSString* latestVersion = [resultsArray[0] objectForKey:@"version"];
                NSString* bugFix = [resultsArray[0] objectForKey:@"releaseNotes"];
                // 检测当前版本
                NSString* currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                // 两个版本比较
                if ([latestVersion doubleValue]>[currentVersion doubleValue]) {
                    // 更新主界面，弹出alertView
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^(void){
                        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"有新版本%@",latestVersion] message:[NSString stringWithFormat:@"* 可查询任意一天的运动量\n* 可将运动结果分享到微信、新浪微博等平台\n%@",bugFix] delegate:self cancelButtonTitle:@"忽略" otherButtonTitles:@"去升级", nil];
                        [alertView show];
                    }];
                }
                NSLog(@"%@,%@",latestVersion,currentVersion);
            } else {
                NSLog(@"%@",[jsonError description]);
            }
        } else {
            NSLog(@"%@",[connectionError description]);
        }
    }];
    
    // 从服务器端下载act.json、act_full.json
    [self downloadFiles];
    // 获取documents文件路径
    NSString* home = NSHomeDirectory(); // 路径
    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
    // 处理act.json
    NSString* actfilePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"act.json"]];
    NSData* actData = [NSData dataWithContentsOfFile:actfilePath];
    if (actData==nil) { // documents中没有文件
        // mainBundle文件导入
        actData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"act.json" ofType:nil]];
        [actData writeToFile:actfilePath atomically:YES];
    }
    // cache中act.json文件导入
    actData = [NSData dataWithContentsOfFile:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"act.json"]];
    if (actData!=nil) {
        [actData writeToFile:actfilePath atomically:YES];
    }
#warning 提取数组！！！
#warning 测试用：mainBundle文件导入，不加这段暂时不能运行
    actData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"act.json" ofType:nil]];
    [actData writeToFile:actfilePath atomically:YES];
    // 处理act_full.json
    NSString* actFullfilePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"act_full.json"]];
    NSData* actFullData = [NSData dataWithContentsOfFile:actFullfilePath];
    if (actFullData==nil) {
        actFullData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"act_full.json" ofType:nil]];
        [actFullData writeToFile:actFullfilePath atomically:YES];
    }
    // cache中act_full.json文件导入
    actFullData = [NSData dataWithContentsOfFile:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"act_full.json"]];
    if (actFullData!=nil) {
        [actFullData writeToFile:actFullfilePath atomically:YES];
    }
#warning 提取数组！！！
#warning 测试用：mainBundle文件导入，不加这段暂时不能运行
    actFullData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"act_full.json" ofType:nil]];
    [actFullData writeToFile:actFullfilePath atomically:YES];
    
    // 判断是否第一次登录
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        
                // 系统默认偏好设置
                NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                // 存储数据
                [defaults setObject:[NSString stringWithFormat:@"%d",1] forKey:@"gender"];
                NSString *birthDateStr = @"1992-01-01 00:00:00";
                [defaults setObject:[NSString stringWithFormat:@"%@",birthDateStr] forKey:@"birthdate"];
                NSLog(@"%@",birthDateStr);
        
                [defaults setObject:[NSString stringWithFormat:@"%d",160] forKey:@"height"];
                [defaults setObject:[NSString stringWithFormat:@"%d",50] forKey:@"weight"];
                // 立刻同步
                [defaults synchronize];
                NSLog(@"第一次使用新版本");
                NSLog(@"gender--%@,birthdate--%@,height--%@,weight--%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"gender"],[[NSUserDefaults standardUserDefaults] objectForKey:@"birthdate"],[[NSUserDefaults standardUserDefaults] objectForKey:@"height"],[[NSUserDefaults standardUserDefaults] objectForKey:@"weight"]);
        
    }else {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
        
        //        //不是第一次使用这个版本
        //        //不显示状态
        //        application.statusBarHidden =NO;
        //        //去调用主界面的内容
        //        self.window.rootViewController = [[MainController alloc] init];
                NSLog(@"不是第一次使用新版本");
                NSLog(@"gender--%@,birthdate--%@,height--%@,weight--%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"gender"],[[NSUserDefaults standardUserDefaults] objectForKey:@"birthdate"],[[NSUserDefaults standardUserDefaults] objectForKey:@"height"],[[NSUserDefaults standardUserDefaults] objectForKey:@"weight"]);
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:^(){
        //程序在10分钟内未被系统关闭或者强制关闭，则程序会调用此代码块，可以在这里做一些保存或者清理工作，程序在后台关闭，则运动自动存储
        [self.willTerminateDelegate saveLastRecord];
        [self uploadFiles];
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self.willTerminateDelegate saveLastRecord];
    [self uploadFiles];
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [WXApi handleOpenURL:url delegate:self];
    return [WeiboSDK handleOpenURL:url delegate:self];
    return [TencentOAuth HandleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
    return [WeiboSDK handleOpenURL:url delegate:self];
    return [TencentOAuth HandleOpenURL:url];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.vajaspine.Macaca" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Macaca" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Macaca.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - shareDelegate

- (void)changeScene:(NSInteger)scene {
    _scene = scene;
}

- (void)sendByWeixin {
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        // 获取过去24小时的运动排名和热量消耗
        TimeIntervalStat* past24State = [[TimeIntervalStat alloc] init];
        double calaries = [past24State caloriesInPast24Hour];
        double rank = [past24State rankInPast24Hour:calaries];
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = @"猕猴桃 - 你的运动记录专家";
        if (rank<0.3) {
            message.description = [NSString stringWithFormat:@"督促运动的神器，140多种日常运动可随意添加到首页，轻轻一点即可记录每日运动时间，精确计算运动消耗热量，你也赶快动起来吧！"];
        } else {
            message.description = [NSString stringWithFormat:@"督促运动的神器，我1天内已消耗%.f大卡热量，超过全国%.f%@用户，你也赶快动起来吧！",calaries,rank*100,@"%"];
        }
        [message setThumbImage:[UIImage imageNamed:@"Icon-60.png"]];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = @"http://itunes.apple.com/app/id966621372?mt=8";
        
        message.mediaObject = ext;
        // message.mediaTagName = @"WECHAT_TAG_JUMP_SHOWRANK";
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = _scene;
        [WXApi sendReq:req];
    } else if ([WXApi isWXAppSupportApi]==NO && [WXApi isWXAppInstalled]==YES) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"当前微信版本不支持分享，是否下载新版本微信？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    } else if ([WXApi isWXAppInstalled]==NO) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"请先安装微信！" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)sendByWeibo {
    if ([WeiboSDK isWeiboAppInstalled] && [WeiboSDK isCanShareInWeiboAPP]) {
        // 获取过去24小时的运动排名和热量消耗
        TimeIntervalStat* past24State = [[TimeIntervalStat alloc] init];
        double calaries = [past24State caloriesInPast24Hour];
        double rank = [past24State rankInPast24Hour:calaries];
        // 授权
        WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
        authRequest.redirectURI = @"http://www.sina.com";
        authRequest.scope = @"all";
        authRequest.userInfo = @{@"ShareMessageFrom": @"AppDelegate",
                                 @"Other_Info_1": [NSNumber numberWithInt:123],
                                 @"Other_Info_2": @[@"obj1", @"obj2"],
                                 @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
        
        WBMessageObject *message = [WBMessageObject message];
        if (rank<0.3) {
            message.text = NSLocalizedString(@"督促运动的神器，140多种日常运动可随意添加到首页，轻轻一点即可记录每日运动时间，精确计算运动消耗热量，你也赶快动起来吧！http://itunes.apple.com/app/id966621372?mt=8", nil);
        } else {
            NSString* text = [NSString stringWithFormat:@"督促运动的神器，我1天内已消耗%.f大卡热量，超过全国%.f%@用户，你也赶快动起来吧！http://itunes.apple.com/app/id966621372?mt=8",calaries,rank*100,@"%"];
            message.text = NSLocalizedString(text, nil);
        }
        
        WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
        request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                             @"Other_Info_1": [NSNumber numberWithInt:123],
                             @"Other_Info_2": @[@"obj1", @"obj2"],
                             @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
        //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
        [WeiboSDK sendRequest:request];
    } else if ([WeiboSDK isCanShareInWeiboAPP]==NO && [WeiboSDK isWeiboAppInstalled]==YES) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"当前新浪微博版本不支持分享，是否下载新版本新浪微博？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    } else if ([WeiboSDK isWeiboAppInstalled]==NO) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"请先安装新浪微博！" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}

- (void)sendByQQKongjian {
    // 获取过去24小时的运动排名和热量消耗
    TimeIntervalStat* past24State = [[TimeIntervalStat alloc] init];
    double calaries = [past24State caloriesInPast24Hour];
    double rank = [past24State rankInPast24Hour:calaries];
    NSString *utf8String = @"http://itunes.apple.com/app/id966621372?mt=8";
    NSString *title = @"猕猴桃 - 你的运动记录专家";
    NSString *previewImageUrl = @"http://www.auv-studio.com/product/kiwi/image/kiwi.png";
    NSString* description;
    if (rank<0.3) {
        description = @"督促运动的神器，140多种日常运动可随意添加到首页，轻轻一点即可记录每日运动时间，精确计算运动消耗热量，你也赶快动起来吧！";
    } else {
        description = [NSString stringWithFormat:@"督促运动的神器，我1天内已消耗%.f大卡热量，超过全国%.f%@用户，你也赶快动起来吧！",calaries,rank*100,@"%"];
    }
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:utf8String]
                                title:title
                                description:description
                                previewImageURL:[NSURL URLWithString:previewImageUrl]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        if ([alertView.title isEqualToString:@"请先安装微信！"] || [alertView.title isEqualToString:@"当前微信版本不支持分享，是否下载新版本微信？"]) {
            NSString* str = [WXApi getWXAppInstallUrl];
            NSURL* url = [NSURL URLWithString:str];
            [[UIApplication sharedApplication] openURL:url];
        } else if ([alertView.title isEqualToString:@"请先安装新浪微博！"] || [alertView.title isEqualToString:@"当前新浪微博版本不支持分享，是否下载新版本新浪微博？"]) {
            NSString* str = [WeiboSDK getWeiboAppInstallUrl];
            NSURL* url = [NSURL URLWithString:str];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    
}

#pragma mark - WXApiDelegate
- (void)onReq:(BaseReq *)req {
}
// 处理微信返回状态
- (void)onResp:(BaseResp *)resp {
    UITabBarController* vc = self.window.rootViewController;
    UINavigationController* navVc = vc.viewControllers[0];
    [navVc.topViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma - mark 文件处理

// 上传相关文件
- (void)uploadFiles {
    // 上传更新的文件
    UploadFile *upload = [[UploadFile alloc] init];
    // 服务器地址
    NSString *urlString = @"http://www.auv-studio.com/index.php";
    // 获取上传文件的文件夹名称idfv，从keychain里取出帐号密码
    NSString *uuid = [_wrapper objectForKey:(__bridge id)kSecValueData];
    NSLog(@"%@",uuid);
    
    // 将运动记录2015-06.plist文件找到路径，获取文件,上传
    ActDataFile* file = [[ActDataFile alloc] init];
    NSDateFormatter* dayFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"yyyy-MM-dd"];
    file.dateStr = [dayFormat stringFromDate:[NSDate date]];
    NSString* path = [file getFilePath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    // 上传
    [upload uploadFileWithURL:[NSURL URLWithString:urlString] data:data fileName:[NSString stringWithFormat:@"%@.%@",uuid,[[file.dateStr substringToIndex:7] stringByAppendingString:@".plist"]]];
    
    
    // 将act_full.json文件找到路径，获取文件，上传
    NSString* home = NSHomeDirectory();
    NSString* docPath = [home stringByAppendingPathComponent:@"Documents"];
    path = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"act_full.json"]];
    data = [NSData dataWithContentsOfFile:path];
    // 上传
    [upload uploadFileWithURL:[NSURL URLWithString:urlString] data:data fileName:[NSString stringWithFormat:@"%@.act_full.json",uuid]];
    
    // 将act_full.json文件复制成txt文件，并找到路径，获取文件
    path = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"act.json"]];
    data = [NSData dataWithContentsOfFile:path];
    // 上传
    [upload uploadFileWithURL:[NSURL URLWithString:urlString] data:data fileName:[NSString stringWithFormat:@"%@.act.json",uuid]];
    
    // 延迟退出程序
    [NSThread sleepForTimeInterval:3.0];
    
}

// 下载相关文件
- (void)downloadFiles {
    NSURL* actFileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.auv-studio.com/kiwi/user_file/%@.act.json",[_wrapper objectForKey:(__bridge id)kSecValueData]]];
    NSLog(@"%@",actFileUrl);
    NSURL* actFullFileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.auv-studio.com/kiwi/user_file/%@.act_full.json",[_wrapper objectForKey:(__bridge id)kSecValueData]]];
    // 下载act.json文件到cache
    FileDownload* downloadAct = [[FileDownload alloc] init];
    downloadAct.fileName = @"act.json";
    [downloadAct downloadFileWithURL:actFileUrl];
    // 下载act.json文件到cache
    FileDownload* downloadActFull = [[FileDownload alloc] init];
    downloadActFull.fileName = @"act_full.json";
    [downloadActFull downloadFileWithURL:actFullFileUrl];
}

@end
