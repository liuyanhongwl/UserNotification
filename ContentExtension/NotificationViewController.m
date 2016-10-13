//
//  NotificationViewController.m
//  ContentExtension
//
//  Created by Hong on 16/10/11.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <AVFoundation/AVFoundation.h>

@interface NotificationViewController () <UNNotificationContentExtension, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIView *customInputView;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, copy) void (^completion)(UNNotificationContentExtensionResponseOption option);

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    
//    self.preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 200);
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = [NSString stringWithFormat:@"%@ [modified]", notification.request.content.title];
    self.subLabel.text = [NSString stringWithFormat:@"%@ [modified]", notification.request.content.body];
//    self.imageView.image = [UIImage imageNamed:@"hong.png"];
//    self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img1.gtimg.com/sports/pics/hv1/194/44/2136/138904814.jpg"]]];
    
    UNNotificationAttachment *attachment = notification.request.content.attachments.firstObject;
    if (attachment) {
        if ([attachment.URL startAccessingSecurityScopedResource]) {
            self.imageView.image = [UIImage imageWithContentsOfFile:attachment.URL.path];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [attachment.URL stopAccessingSecurityScopedResource];
            });
        }
    }
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption option))completion
{
    if ([response.actionIdentifier isEqualToString:@"action-like"]) {
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"like" ofType:@"m4a"]] error:nil];
        [self.player play];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.player stop];
            self.player = nil;
            completion(UNNotificationContentExtensionResponseOptionDismiss);
        });
        
    }else if ([response.actionIdentifier isEqualToString:@"action-collect"]){
        self.label.text = @"收藏成功~";
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(UNNotificationContentExtensionResponseOptionDismiss);
        });
        
    }else if ([response.actionIdentifier isEqualToString:@"action-comment"]){
        self.label.text = [(UNTextInputNotificationResponse *)response userText];
        [self becomeFirstResponder];
        [self.textField becomeFirstResponder];
        
        self.completion = completion;
    }
    
    //这里如果点击的action类型为UNNotificationActionOptionForeground，
    //则即使completion设置成Dismiss的，通知也不能消失
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (UIView *)inputAccessoryView
{
    return self.customInputView;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(8, 8, CGRectGetWidth(self.view.frame) - 80, 28)];
        _textField.backgroundColor = [UIColor redColor];
        _textField.textColor = [UIColor whiteColor];
        _textField.returnKeyType = UIReturnKeySend;
        _textField.delegate = self;
    }
    return _textField;
}

- (UIView *)customInputView
{
    if (!_customInputView) {
        _customInputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
        _customInputView.backgroundColor = [UIColor orangeColor];
        [_customInputView addSubview:self.textField];
        
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        cancel.frame = CGRectMake(CGRectGetMaxX(self.textField.frame) + 8, 8, 64, 28);
        [cancel addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_customInputView addSubview:cancel];
    }
    return _customInputView;
}

- (void)cancelButtonAction:(UIButton *)button
{
    [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.label.text = textField.text;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.completion(UNNotificationContentExtensionResponseOptionDismiss);
    });
    return YES;
}

//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    self.label.text = textField.text;
//    
//    self.completion(UNNotificationContentExtensionResponseOptionDismiss);
//}

@end
