//
//  DownloadManager.m
//  TestingPlatform
//
//  Created by Robert Ryan on 11/21/12.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
