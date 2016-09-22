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

#pragma mark - Add Local Notification

- (void)addNotificationWithTimeIntervalTrigger;

- (void)addNotificationWithCalendarTrigger;

- (void)addNotificationWithLocationTrigger;

#pragma mark - Add Remote Notification

#pragma mark - Categories

- (void)setCategories;

- (void)addNotificationWithCategroy1;

- (void)addNotificationWithCategroy2;

- (void)addNotificationWithCategroy3;

#pragma mark - 附件

- (void)addNotificationWithAttachmentType:(AttachmentType)type;

#pragma mark - AppDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

@end
