//
//  Download.h
//  TestingPlatform
//
//  Created by Robert Ryan on 11/13/12.
//
//

#import <Foundation/Foundation.h>

@class Download;

@protocol DownloadDelegateProtocol <NSObject>

// these are the delegate protocol methods regarding the success or failure of a download

- (void)downloadDidFinishLoading:(Download *)download;
- (void)downloadDidFail:(Download *)download;

@optional

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

- (void)download;

// these are the properties that the caller can inquire regarding the status of a download

@property (getter = isDownloading) BOOL downloading;
@property long long expectedContentLength;
@property long long progressContentLength;

// this is delegate that this class notifies regarding the progress of a download

@property (nonatomic, weak) id<DownloadDelegateProtocol> delegate;

@end
