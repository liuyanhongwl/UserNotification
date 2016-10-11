//
//  ViewController.m
//  UserNotification
//
//  Created by Hong on 16/9/20.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "ViewController.h"
#import "UserNotification.h"
#import "DownloadManager.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (nonatomic, copy) NSArray *sectionTitles;
@property (nonatomic, copy) NSArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak typeof(self) weakSelf = self;
    [[DownloadManager sharedInstance] setProgressBlock:^(float persent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progress.progress = persent;
        });
    }];
    
    self.sectionTitles = @[
                           @"本地三种推送",
                           @"本地-Category",
                           @"本地-附件",
                           @"远程推送",
                           @"远程-附件",
                           @"自定义推送UI"
                           ];
    
    self.datas = @[
                   @[
                       @"时间戳定时推送",
                       @"周期性定时推送",
                       @"指定位置推送"
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
                       ],
                   @[
                       @"远程推送-普通",
                       @"远程推送-普通下载",
                       @"远程推送-静默下载"
                       ],
                   @[
                       @"远程-附件"
                       ],
                   @[
                       @"自定义-本地",
                       @"自定义-远程",
                       @"自定义-添加策略行为"
                       ]
                   ];
    
    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc] initWithTitle:@"崩" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)],
                                                [[UIBarButtonItem alloc] initWithTitle:@"stop" style:UIBarButtonItemStylePlain target:self action:@selector(stopAction:)],
                                                [[UIBarButtonItem alloc] initWithTitle:@"pause" style:UIBarButtonItemStylePlain target:self action:@selector(pauseAction:)],
                                                [[UIBarButtonItem alloc] initWithTitle:@"start" style:UIBarButtonItemStylePlain target:self action:@selector(startAction:)]
                                                ];
    
}

#pragma mark - Action

- (void)stopAction:(UIBarButtonItem *)item
{
    [[DownloadManager sharedInstance] stop];
}

- (void)pauseAction:(UIBarButtonItem *)item
{
    [[DownloadManager sharedInstance] pause];
}

- (void)startAction:(UIBarButtonItem *)item
{
    [[DownloadManager sharedInstance] start];
}

- (void)rightBarButtonAction:(UIBarButtonItem *)item
{
    NSArray *a = @[];
    [a objectAtIndex:1];
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
        //本地三种推送
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
        //本地-Category
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
        
    }else if (indexPath.section == 2){
        //本地-附件
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
        
    }else if (indexPath.section == 3){
        //远程推送
        
        //远程推送，这里的方法没有具体实现，只是在方法内部注释了远程推送的apns格式。
        switch (indexPath.row) {
            case 0:
            {
                [[UserNotification sharedNotification] addRemoteNotification];
            }
                break;
            case 1:
            {
                [[UserNotification sharedNotification] addRemoteNotificationDownload];
            }
                break;
            case 2:
            {
                [[UserNotification sharedNotification] addRemoteNotificationSilentDownload];
            }
                break;
            case 3:
            {
                [[UserNotification sharedNotification] addRemoteNotificationCategory];
            }
                
            default:
                break;
        }
    }else if (indexPath.section == 4){
        //远程-附件
        switch (indexPath.row) {
            case 0:
            {
                [[UserNotification sharedNotification] addRemoteNotificationAttachment];
            }
                break;
                
            default:
                break;
        }
    }else if (indexPath.section == 5){
        //自定义推送UI
        switch (indexPath.row) {
            case 0:
            {
                [[UserNotification sharedNotification] addLocalWithCustomUI];
            }
                break;
            case 1:
            {
                [[UserNotification sharedNotification] addRemoteWithCustomUI];
            }
                break;
            case 2:
            {
                [[UserNotification sharedNotification] addCustomUICategory];
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
