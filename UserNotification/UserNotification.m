//
//  UserNotification.m
//  UserNotification
//
//  Created by Hong on 16/9/20.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "UserNotification.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "DownloadManager.h"

/*
 附件通知（图片、音频、视频）:有大小、格式限制，而且附件要在本地。
    本地：content.attachments = @[attachment];
    远程：apns中包含一个"mutable-content":1字段,使用UNNotificationServiceExtension，你有30秒的时间处理这个通知，可以同步下载图像和视频到本地，然后包装为一个UNNotificationAttachment扔给通知，这样就能展示用服务器获取的图像或者视频了。这里需要注意：如果数据处理失败，超时，extension会报一个崩溃信息，但是通知会用默认的形式展示出来，app不会崩溃。
 
 管理推送周期
    本地：通过id更新request。
        1. addNotificationRequest:withCompletionHandler: 在 id 不变的情况下重新添加，就可以刷新原有的推送。
        2. 删除计划的推送 [center removePendingNotificationRequestsWithIdentifiers:@[requestIdentifier]];
    远程：通过新的字段 apns-collapse-id
    此外 UNUserNotificationCenter.h 中还有诸如删除所有推送、查看已经发出的推送、删除已经发出的推送等等强大的接口
 
 收到通知的回调：
    本地推送：
        1. 用户不在前台时，未知。
        2. 用户在前台，（userNotificationCenter:willPresentNotification:withCompletionHandler）
    远程推送：
        1. 被用户手动划掉的用户不能收到远程推送的回调。
        2. 在后台的应用要想收到远程推送的回调，需要增加"content-available":1字段。(application:didReceiveRemoteNotification:fetchCompletionHandler:)
        3. 在前台，没有"content-available":1字段时，只调用（userNotificationCenter:willPresentNotification:withCompletionHandler）。有"content-available":1字段，则先调用(application:didReceiveRemoteNotification:fetchCompletionHandler),再调用(userNotificationCenter:willPresentNotification:withCompletionHandler)。
 操作的回调：
    本地推送：
        1. 被手动划掉的用户，可以收到本地推送操作的回调。(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:) //并且想获取清除通知的回调，category需要配置UNNotificationCategoryOptionCustomDismissAction。
    远程推送：
        1. 与本地推送的操作回调相同。增加"category":"categoryId"字段

 */

@interface UserNotification ()<UNUserNotificationCenterDelegate>

@end

@implementation UserNotification

MImplementeSharedInstance(sharedNotification)

- (instancetype)init
{
    self = [super init];
    if (self) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }
    return self;
}

- (void)registerNotification
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNAuthorizationOptions options = UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert;
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //允许
            NSLog(@"允许注册通知");
            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                NSLog(@"%@", settings);
            }];
            //注册
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }else{
            //不允许
            NSLog(@"不允许注册通知");
        }
    }];
}

#pragma mark - 添加 本地推送

- (void)addNotificationWithTimeIntervalTrigger
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"时间戳定时推送";
    content.subtitle = @"subtitle";
    content.body = @"Copyright © 2016年 Hong. All rights reserved.";
    content.sound = [UNNotificationSound soundNamed:@"test.caf"];
    
    /*重点开始*/
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    /*重点结束*/
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"TimeInterval" content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加时间戳定时推送 : %@", error ? [NSString stringWithFormat:@"error : %@", error] : @"success");
    }];
}

- (void)addNotificationWithCalendarTrigger
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"周期性定时推送";
    content.subtitle = @"subtitle";
    content.body = @"Copyright © 2016年 Hong. All rights reserved.";
    content.sound = [UNNotificationSound defaultSound];
    
    /*重点开始*/
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekday = 4; //周三
    components.hour = 13; //13点
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    /*重点结束*/
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Calendar" content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加周期性定时推送 ：%@", error ? [NSString stringWithFormat:@"error : %@", error] : @"success");
    }];
}

- (void)addNotificationWithLocationTrigger
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"指定位置推送";
    content.subtitle = @"subtitle";
    content.body = @"Copyright © 2016年 Hong. All rights reserved.";
    content.sound = [UNNotificationSound defaultSound];
    
    /*重点开始*/
    CLLocationCoordinate2D cen = CLLocationCoordinate2DMake(39.989898,116.333404);
    CLRegion *region = [[CLCircularRegion alloc] initWithCenter:cen radius:100 identifier:@"center"];
    region.notifyOnEntry = NO;
    region.notifyOnExit = YES;
    UNLocationNotificationTrigger *trigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
    /*重点结束*/
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Location" content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加指定位置推送 ：%@", error ? [NSString stringWithFormat:@"error : %@", error] : @"success");
    }];
}

#pragma mark - Categories

- (void)setCategories
{
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"需要解锁" options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"启动app" options:UNNotificationActionOptionForeground];
    //intentIdentifiers，需要填写你想要添加到哪个推送消息的 id
    UNNotificationCategory *category1 = [UNNotificationCategory categoryWithIdentifier:@"category1" actions:@[action1, action2] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    
    UNNotificationAction *action3 = [UNNotificationAction actionWithIdentifier:@"action3" title:@"红色样式" options:UNNotificationActionOptionDestructive];
    UNNotificationAction *action4 = [UNNotificationAction actionWithIdentifier:@"action4" title:@"红色解锁启动" options:UNNotificationActionOptionAuthenticationRequired | UNNotificationActionOptionDestructive | UNNotificationActionOptionForeground];
    UNNotificationCategory *category2 = [UNNotificationCategory categoryWithIdentifier:@"category2" actions:@[action3, action4] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
    UNTextInputNotificationAction *action5 = [UNTextInputNotificationAction actionWithIdentifier:@"action5" title:@"" options:UNNotificationActionOptionForeground textInputButtonTitle:@"回复" textInputPlaceholder:@"写你想写的"];
    UNNotificationCategory *category3 = [UNNotificationCategory categoryWithIdentifier:@"category3" actions:@[action5] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:category1, category2, category3, nil]];
}

- (void)addNotificationWithCategroy1
{
    UNMutableNotificationContent *content = [self contentWithSubtitle:@"category样式一"];
    /*重点开始*/
    content.categoryIdentifier = @"category1";
    /*重点结束*/
    
    [self addDelayNotificationWithContent:content];
}

- (void)addNotificationWithCategroy2
{
    UNMutableNotificationContent *content = [self contentWithSubtitle:@"category样式二"];
    
    /*重点开始*/
    content.categoryIdentifier = @"category2";
    /*重点结束*/
    
    [self addDelayNotificationWithContent:content];
}

- (void)addNotificationWithCategroy3
{
    UNMutableNotificationContent *content = [self contentWithSubtitle:@"category样式三带文本输入"];
    
    /*重点开始*/
    content.categoryIdentifier = @"category3";
    /*重点结束*/
    
    [self addDelayNotificationWithContent:content];
}

#pragma mark - 本地-附件

- (void)addNotificationWithAttachmentType:(AttachmentType)type
{
    NSString *contentString = @"";
    NSString *path = @"";
    switch (type) {
        case AttachmentTypeImage:
            contentString = @"附件-图片";
            path = [[NSBundle mainBundle] pathForResource:@"hong" ofType:@"png"];
            break;
            
        case AttachmentTypeImageGif:
            contentString = @"附件-图片-GIF";
            path = [[NSBundle mainBundle] pathForResource:@"超人" ofType:@"gif"];
            break;
            
        case AttachmentTypeAudio:
            contentString = @"附件-音频";
            path = [[NSBundle mainBundle] pathForResource:@"赵薇-烟雨蒙蒙" ofType:@"mp3"];
            break;
            
        case AttachmentTypeMovie:
            contentString = @"附件-视频";
            path = [[NSBundle mainBundle] pathForResource:@"IMG_0723" ofType:@"mp4"];
            break;
            
        default:
            break;
    }
    
    UNMutableNotificationContent *content = [self contentWithSubtitle:contentString];
    
    /*重点开始*/
    NSError *error = nil;
    //这里url必须是file url。
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"atta1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
    if (error) {
        NSLog(@"attachment error : %@", error);
    }
    if (attachment) {
        content.attachments = @[attachment];
    }
    /*重点结束*/
    
    [self addDelayNotificationWithContent:content];
}

#pragma mark - 添加 远程推送

- (void)addRemoteNotification
{
    //ios10新版文案多样推送
    /*
     {
     "aps":{
         "alert":{
                "title":"Testing.. (52)",
                "subtitle":"subtitle",
                "body":"body"},
         "badge":1,
         "sound":"default"}
     }
     */
}

- (void)addRemoteNotificationDownload
{
    //后台做一些操作增加字段："content-available":1
    /*
     {
     "aps":{"alert":"Testing.. (34)",
            "badge":1,
            "sound":"default",
            "content-available":1}
     }
     */
}

- (void)addRemoteNotificationSilentDownload
{
    //去掉alert、badge、sound字段实现静默推送，增加增加字段："content-available":1，也可以在后台做一些事情。
    /*
     {
     "aps":{"content-available":1}
     }
     */
}

- (void)addRemoteNotificationCategory
{
    //指定操作策略，需增加字段："category":"categoryId"
    /*
     {
     "aps":{"alert":"Testing.. (34)",
     "badge":1,
     "sound":"default",
     "category":"category1"}
     }
     */
}

#pragma mark - 远程-附件

- (void)addRemoteNotificationAttachment
{
    //为了给远程推送增加附件，使推送是可变的，需增加字段："mutable-content":1
    /*
     {
     "aps":{"alert":"Testing.. (34)",
     "badge":1,
     "sound":"default",
     "mutable-content":1}
     }
     */
}

#pragma mark - 自定义推送UI

- (void)addLocalWithCustomUI
{
    //只要指定categoryIdentifier是Notification Content Extension（通知内容扩展）里配置文件里面category的id之一，就可以调用扩展的通知样式。
    UNMutableNotificationContent *content = [self contentWithSubtitle:@"Notification Content Extension"];
    /*重点开始*/
    content.categoryIdentifier = @"category-custom-ui";
    /*重点结束*/
    
    //添加附件
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hong" ofType:@"png"];
    UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"atta1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
    if (error) {
        NSLog(@"attachment error : %@", error);
    }
    if (attachment) {
        content.attachments = @[attachment];
    }
    
    [self addDelayNotificationWithContent:content];
}

- (void)addRemoteWithCustomUI
{
    //指定操作策略是Notification Content Extension（通知内容扩展）里配置文件里面category的id之一
    /*
     {
     "aps":{"alert":"Testing.. (34)",
     "badge":1,
     "sound":"default",
     "category":"category-custom-ui"}
     }
     */
}

- (void)addCustomUICategory
{
    UNNotificationAction *likeAction = [UNNotificationAction actionWithIdentifier:@"action-like" title:@"赞" options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationAction *collectAction = [UNNotificationAction actionWithIdentifier:@"action-collect" title:@"收藏" options:UNNotificationActionOptionAuthenticationRequired];
    UNTextInputNotificationAction *commentAction = [UNTextInputNotificationAction actionWithIdentifier:@"action-comment" title:@"评论" options:UNNotificationActionOptionDestructive textInputButtonTitle:@"发送" textInputPlaceholder:@"输入你的评论"];
    
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"category-custom-ui" actions:@[likeAction, collectAction, commentAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:category, nil]];
}

#pragma mark - 获取通知状态


#pragma mark - Private

- (UNMutableNotificationContent *)contentWithSubtitle:(NSString *)subtitle
{
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"推送";
    content.subtitle = subtitle;
    content.body = @"Copyright © 2016年 Hong. All rights reserved.";
    content.sound = [UNNotificationSound soundNamed:@"test.caf"];
    
    return content;
}

- (void)addDelayNotificationWithContent:(UNNotificationContent *)content
{
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"TimeInterval" content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加推送 : %@", error ? [NSString stringWithFormat:@"error : %@", error] : @"success");
    }];
}

#pragma mark - UNUserNotificationCenterDelegate

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSLog(@"willPresentNotification");
    completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
    NSLog(@"didReceiveNotificationResponse : %@", response);
    completionHandler();
}

#pragma mark - AppDelegate

- (void)application:(UIApplication *)ap·plication didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"注册通知成功 device token : %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"注册通知失败");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    NSLog(@"didReceiveRemoteNotification---application.state=%ld", application.applicationState);
    
    [[DownloadManager sharedInstance] setCompletionBlock:^(BOOL finish, BOOL stop) {
        NSLog(@"completionblock");
        completionHandler(UIBackgroundFetchResultNewData);
    }];
    [[DownloadManager sharedInstance] start];
}

@end
