//
//  Download.h
//  TestingPlatform
//
//  Created by Robert Ryan on 11/13/12.
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

@class Download;

@protocol DownloadDelegateProtocol <NSObject>

@optional

// these are the delegate protocol methods regarding the success or failure of a download

- (void)downloadDidFinishLoading:(Download *)download;
- (void)downloadDidFail:(Download *)download;

// this is the optional protocol method to inform the caller regarding the progress of an ongoing download

- (void)downloadDidReceiveData:(Download *)download;

@end

@interface Download : NSObject <NSURLConnectionDelegate>

// these are the properties the caller must set before initiating a download

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSURL *url;

// this is a convenience method to create download object and set filename and url properties

- (id)initWithFilename:(NSString *)filename URL:(NSURL *)url delegate:(id<DownloadDelegateProtocol>)delegate;

// this is the method to initiate the download

- (void)start;

// this is the method to cancel a download in progress, if needed

- (void)cancel;

// these are the properties that the caller can inquire regarding the status of a download

@property (getter = isDownloading) BOOL downloading;
@property long long expectedContentLength;
@property long long progressContentLength;
@property (nonatomic, strong) NSError *error;

// this is delegate that this class notifies regarding the progress of a download

@property (nonatomic, weak) id<DownloadDelegateProtocol> delegate;

@end
