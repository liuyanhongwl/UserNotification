//
//  ViewController.m
//  UserNotification
//
//  Created by Hong on 16/9/20.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "ViewController.h"
#import "UserNotification.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *sectionTitles;
@property (nonatomic, copy) NSArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.sectionTitles = @[
                           @"Local Notification",
                           @"Remote Notification",
                           @"Category",
                           @"附件"
                           ];
    
    self.datas = @[
                   @[
                       @"时间戳定时推送",
                       @"周期性定时推送",
                       @"指定位置推送"
                       ],
                   @[
                       
                       ],
                   @[
                       @"设置categories",
                       @"推送category样式一",
                       @"推送category样式二",
                       @"推送category样式三带文本输入"
                       ],
                   @[
                       @"附件-图片",
                       @"附件-图片-GIF",
                       @"附件-音频",
                       @"附件-视频"
                       ]
                   ];
    
}

#pragma mark - Delegate
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datas objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = self.datas[indexPath.section][indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sectionTitles[section];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:
            {
                [[UserNotification sharedNotification] addNotificationWithTimeIntervalTrigger];
            }
                break;
            case 1:
            {
                [[UserNotification sharedNotification] addNotificationWithCalendarTrigger];
            }
                break;
            case 2:
            {
                [[UserNotification sharedNotification] addNotificationWithLocationTrigger];
            }
                break;
            default:
                break;
        }
        
    }else if (indexPath.section == 1){
        
    }else if (indexPath.section == 2){

        switch (indexPath.row) {
            case 0:
            {
                [[UserNotification sharedNotification] setCategories];
            }
                break;
            case 1:
            {
                [[UserNotification sharedNotification] addNotificationWithCategroy1];
            }
                break;
            case 2:
            {
                [[UserNotification sharedNotification] addNotificationWithCategroy2];
            }
                break;
            case 3:
            {
                [[UserNotification sharedNotification] addNotificationWithCategroy3];
            }
                break;
            default:
                break;
        }
        
    }else{
        
        switch (indexPath.row) {
            case 0:
            {
                [[UserNotification sharedNotification] addNotificationWithAttachmentType:AttachmentTypeImage];
            }
                break;
            case 1:
            {
                [[UserNotification sharedNotification] addNotificationWithAttachmentType:AttachmentTypeImageGif];
            }
                break;
            case 2:
            {
                [[UserNotification sharedNotification] addNotificationWithAttachmentType:AttachmentTypeAudio];
            }
                break;
            case 3:
            {
                [[UserNotification sharedNotification] addNotificationWithAttachmentType:AttachmentTypeMovie];
            }
                break;
            default:
                break;
        }
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
