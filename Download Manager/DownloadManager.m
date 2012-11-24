//
//  DownloadManager.m
//  TestingPlatform
//
//  Created by Robert Ryan on 11/21/12.
//
//

#import "DownloadManager.h"
#import "Download.h"

@interface DownloadManager () <DownloadDelegateProtocol>

@end

@implementation DownloadManager

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _downloads = [[NSMutableArray alloc] init];
        _maxConcurrentDownloads = 4;
    }
    
    return self;
}

- (id)initWithDelegate:(id<DownloadManagerDelegateProtocol>)delegate
{
    self = [self init];
    
    if (self)
    {
        _delegate = delegate;
    }
    
    return self;
}

- (void)addDownloadWithFilename:(NSString *)filename URL:(NSURL *)url
{
    Download *download = [[Download alloc] initWithFilename:filename URL:url delegate:self];
    
    [self.downloads addObject:download];
    
    [self tryDownloading];
}

- (void)downloadDidFinishLoading:(Download *)download
{
    [self.downloads removeObject:download];
    [self tryDownloading];
    [self.delegate downloadManager:self downloadDidFinishLoading:download];
}

- (void)downloadDidFail:(Download *)download
{
    [self.downloads removeObject:download];
    [self tryDownloading];
    [self.delegate downloadManager:self downloadDidFail:download];
}

- (void)downloadDidReceiveData:(Download *)download
{
    if ([self.delegate respondsToSelector:@selector(downloadManager:downloadDidReceiveData:)])
    {
        [self.delegate downloadManager:self downloadDidReceiveData:download];
    }
}

- (void)tryDownloading
{
    NSInteger activeDownloads = [self countActiveDownloads];
    NSInteger awaitingDownloads = self.downloads.count - activeDownloads;
    
    if (awaitingDownloads > 0 && activeDownloads < self.maxConcurrentDownloads)
    {
        for (Download *download in self.downloads)
        {
            if (!download.downloading)
            {
                [download download];
                return;
            }
        }
    }
}

- (NSInteger)countActiveDownloads
{
    NSInteger activeDownloadCount = 0;
    
    for (Download *download in self.downloads)
    {
        if (download.downloading)
            activeDownloadCount++;
    }
    
    return activeDownloadCount;
}

@end
