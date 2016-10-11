//
//  UserNotification.h
//  UserNotification
//
//  Created by Hong on 16/9/20.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macro.h"

typedef NS_ENUM(NSUInteger, AttachmentType) {
    AttachmentTypeImage,
    AttachmentTypeImageGif,
    AttachmentTypeAudio,
    AttachmentTypeMovie
};

@interface UserNotification : NSObject

MInterfaceSharedInstance(sharedNotification)

- (void)registerNotification;

#pragma mark - 添加 本地推送

- (void)addNotificationWithTimeIntervalTrigger;

- (void)addNotificationWithCalendarTrigger;

- (void)addNotificationWithLocationTrigger;

#pragma mark - Categories

- (void)setCategories;

- (void)addNotificationWithCategroy1;

- (void)addNotificationWithCategroy2;

- (void)addNotificationWithCategroy3;

#pragma mark - 本地-附件

- (void)addNotificationWithAttachmentType:(AttachmentType)type;

#pragma mark - 添加 远程推送

- (void)addRemoteNotification;

- (void)addRemoteNotificationDownload;

- (void)addRemoteNotificationSilentDownload;

- (void)addRemoteNotificationCategory;

#pragma mark - 远程-附件

- (void)addRemoteNotificationAttachment;

#pragma mark - 自定义推送UI

- (void)addLocalWithCustomUI;

- (void)addRemoteWithCustomUI;

- (void)addCustomUICategory;

#pragma mark - AppDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;

@end
