//
//  DownloadManager.h
//  TestingPlatform
//
//  Created by Robert Ryan on 11/21/12.
//
//

#import <Foundation/Foundation.h>
#import "Download.h"

@class DownloadManager;
@class Download;

@protocol DownloadManagerDelegateProtocol <NSObject>

// these are the delegate protocol methods regarding the success or failure of a particular download

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFinishLoading:(Download *)download;
- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFail:(Download *)download;

@optional

// this is the optional protocol method to inform the caller regarding the progress of a particular, ongoing download

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidReceiveData:(Download *)download;

@end

@interface DownloadManager : NSObject

// this is the method to create the DownloadManager

- (id)initWithDelegate:(id<DownloadManagerDelegateProtocol>)delegate;

// you may optionally set the number of permissible number of concurrent downloads

@property NSInteger maxConcurrentDownloads;

// this is a list of the ongoing downloads

@property (nonatomic, strong) NSMutableArray *downloads;

// this is the method to add a download to the manager

- (void)addDownloadWithFilename:(NSString *)filename URL:(NSURL *)url;

// this is delegate that this class notifies regarding the progress of the individual downloads

@property (nonatomic, weak) id<DownloadManagerDelegateProtocol> delegate;

@end
