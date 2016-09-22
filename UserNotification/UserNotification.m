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

/*
 后台或者无进程时收到本地通知的回调。
 后台或者无进程时收到本地通知后操作Action的回调。
 附件：有大小、格式限制，而且要在本地。
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

#pragma mark - Add Local Notification

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
    CLLocationCoordinate2D cen = CLLocationCoordinate2DMake(39.990465,116.333386);
    CLRegion *region = [[CLCircularRegion alloc] initWithCenter:cen radius:100 identifier:@"center"];
    region.notifyOnEntry = YES;
    region.notifyOnExit = NO;
    UNLocationNotificationTrigger *trigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
    /*重点结束*/
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Location" content:content trigger:trigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"添加指定位置推送 ：%@", error ? [NSString stringWithFormat:@"error : %@", error] : @"success");
    }];
}

#pragma mark - Add Remote Notification

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

#pragma mark - 附件

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

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"注册通知成功 device token : %@", deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"注册通知失败");
}

@end
