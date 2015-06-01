//
//  AppDelegate.h
//  Macaca
//
//  Created by Julie on 14/12/9.
//  Copyright (c) 2014年 _VAJASPINE_. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

// 程序结束前的代理
@protocol AppDelegeteWillTerminateDelegate <NSObject>
- (void)willTerminateApp;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate,WeiboSDKDelegate,WBHttpRequestDelegate,TencentSessionDelegate,QQApiInterfaceDelegate,UIAlertViewDelegate>
{
    enum WXScene _scene;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) id <AppDelegeteWillTerminateDelegate> willTerminateDelegate;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, strong) TencentOAuth* tencentOAuth;
@property (nonatomic, strong) NSArray* permissions;

@end

