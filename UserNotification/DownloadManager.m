//
//  DownloadManager.m
//  UserNotification
//
//  Created by Hong on 16/9/23.
//  Copyright © 2016年 Hong. All rights reserved.
//

#import "DownloadManager.h"
#import "UserNotification-Swift.h"

@interface DownloadManager ()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSessionDownloadTask *task;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation DownloadManager

MImplementeSharedInstance(sharedInstance)

- (void)start
{
    if (self.task && self.task.state == NSURLSessionTaskStateRunning) {
        return;
    }
    
    ResumeDataTools *tools = [[ResumeDataTools alloc] init];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self localPath];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    BOOL exists = [self existsResumeData];
    if (exists) {
        NSData *resumeData = [NSData dataWithContentsOfFile:[self resumeDataPath]];
        resumeData = [tools correctResumeData:resumeData];
        _task = [self.session downloadTaskWithResumeData:resumeData];
        [self.task resume];
    }else{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://occll6tdq.bkt.clouddn.com/%E8%96%9B%E4%B9%8B%E8%B0%A6%20-%20%E4%BD%A0%E8%BF%98%E8%A6%81%E6%88%91%E6%80%8E%E6%A0%B7.mp3"]];
        _task = [self.session downloadTaskWithRequest:request];
        [self.task resume];
    }
    
    NSLog(@"xxxxstart : %@", [self localPath]);
    
    NSLog(@"start");
}

- (void)pause
{
    __weak typeof(self) weakSelf = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        [weakSelf saveResumeData:resumeData];
        
        if (weakSelf.completionBlock) {
            weakSelf.completionBlock(YES, NO);
        }
    }];
}

- (void)stop
{
    __weak typeof(self) weakSelf = self;
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        [weakSelf saveResumeData:resumeData];
        
        if (weakSelf.completionBlock) {
            weakSelf.completionBlock(YES, NO);
        }
    }];
}

- (NSString *)localPath
{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"download"];
}

- (void)clear
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = [fileManager contentsOfDirectoryAtPath:[self localPath] error:nil];
    for (NSString *path in paths) {
        [fileManager removeItemAtPath:path error:nil];
    }
}

#pragma mark - Private

- (NSURLSession *)session
{
    if (!_session) {
//    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"background"];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:queue];
    }
    return _session;
}

- (BOOL)existsResumeData
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self resumeDataPath]];
}

- (void)saveResumeData:(NSData *)data
{
    if (data) {
        [data writeToFile:[self resumeDataPath] atomically:YES];
    }
}

- (NSString *)resumeDataPath
{
    return [[self localPath] stringByAppendingPathComponent:@"videodata"];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSString *fileName = downloadTask.response.suggestedFilename;
    const char *byte = NULL;
    byte = [fileName cStringUsingEncoding:NSISOLatin1StringEncoding];
    fileName = [NSString stringWithCString:byte encoding:NSUTF8StringEncoding];
    NSString *targetPath = [[self localPath] stringByAppendingPathComponent:fileName];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:targetPath] error:&error];
    if (error) {
        NSLog(@"%s error : %@", __FUNCTION__, error);
    }
    //remove tmp file
    [[NSFileManager defaultManager] removeItemAtURL:location error:&error];
    if (error) {
        NSLog(@"%s error : %@", __FUNCTION__, error);
    }
    //remove resume data file
    [[NSFileManager defaultManager] removeItemAtPath:[self resumeDataPath] error:&error];
    if (error) {
        NSLog(@"%s error : %@", __FUNCTION__, error);
    }
    
    NSLog(@"completion");
    
    if (self.completionBlock) {
        self.completionBlock(YES, NO);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"didWriteData:%lld,\n totalBytesWritten:%lld,\n totalBytesExpectedToWrite:%lld\n", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    if (self.progressBlock) {
        self.progressBlock(totalBytesWritten * 1.0 / totalBytesExpectedToWrite);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    if (downloadTask.error) {
        NSDictionary *userInfo = downloadTask.error.userInfo;
        NSData *resumeData = [userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
        if (resumeData) {
            [self saveResumeData:resumeData];
        }
        
        if (self.completionBlock) {
            self.completionBlock(NO, YES);
        }
    }
}



@end
