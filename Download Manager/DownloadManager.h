//
//  DownloadManager.h
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
