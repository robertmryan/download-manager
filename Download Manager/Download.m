//
//  Download.m
//  TestingPlatform
//
//  Created by Robert Ryan on 11/13/12.
//
//

#import "Download.h"

@interface Download () <NSURLConnectionDelegate>
{
    NSOutputStream *downloadStream;
    NSURLConnection *connection;
    NSString *tempFilename;
}
@end

@implementation Download

- (id)initWithFilename:(NSString *)filename URL:(NSURL *)url delegate:(id<DownloadDelegateProtocol>)delegate
{
    self = [super init];
    
    if (self)
    {
        _filename = filename;
        _url = url;
        _delegate = delegate;
    }
    
    return self;
}

- (BOOL)createFolderForPath:(NSString *)filePath
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folder = [filePath stringByDeletingLastPathComponent];
    BOOL isDirectory;
    
    if (![fileManager fileExistsAtPath:folder isDirectory:&isDirectory])
    {
        // if folder doesn't exist, try to create it
        
        [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
        
        // if fail, report error
        
        if (error)
        {
            NSLog(@"%s folder create failed; err = %@", __FUNCTION__, error);
            return FALSE;
        }
        
        // directory successfully created
        
        return TRUE;
    }
    else if (!isDirectory)
    {
        NSLog(@"%s create directory as file of that name already exists", __FUNCTION__);
        return FALSE;
    }
    
    // directory already existed
    
    return TRUE;
}

- (void)download
{
    // initialize progress variables
    
    self.downloading = YES;
    self.expectedContentLength = -1;
    self.progressContentLength = 0;
    
    // create the download file stream (so we can write the file as we download it
    
    tempFilename = [self pathForTemporaryFileWithPrefix:@"downloads"];
    downloadStream = [NSOutputStream outputStreamToFileAtPath:tempFilename append:NO];
    [downloadStream open];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    connection            = [NSURLConnection connectionWithRequest:request delegate:self];
    NSAssert(connection, @"Connection creation failed");
}

- (void)cleanupConnectionSuccessful:(BOOL)success
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;

    // clean up connection and download steam
    
    if (connection != nil)
    {
        if (!success)
            [connection cancel];
        connection = nil;
    }
    if (downloadStream != nil)
    {
        [downloadStream close];
        downloadStream = nil;
    }
    
    self.downloading = NO;
    
    // if successful, move file and clean up, otherwise just cleanup
    
    if (success)
    {
        if (![self createFolderForPath:self.filename])
            return;

        if ([fileManager fileExistsAtPath:self.filename])
            [fileManager removeItemAtPath:self.filename error:&error];
        
        [fileManager copyItemAtPath:tempFilename toPath:self.filename error:&error];
        [fileManager removeItemAtPath:tempFilename error:&error];
        
        [self.delegate downloadDidFinishLoading:self];
    }
    else
    {
        [fileManager removeItemAtPath:tempFilename error:&error];
        [self.delegate downloadDidFail:self];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*) response
{
    NSInteger statusCode = [response statusCode];
    if (statusCode == 200)
    {
        self.expectedContentLength = [response expectedContentLength];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSInteger       dataLength = [data length];
    const uint8_t * dataBytes  = [data bytes];
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [downloadStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [self cleanupConnectionSuccessful:NO];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
    
    self.progressContentLength += dataLength;
    
    if ([self.delegate respondsToSelector:@selector(downloadDidReceiveData:)])
        [self.delegate downloadDidReceiveData:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cleanupConnectionSuccessful:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self cleanupConnectionSuccessful:NO];
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

//- (void)downloadFile3:(NSString *)filename fromUrl:(NSString *)urlString
//{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSURL *sourceURL = [NSURL URLWithString:urlString];
//    NSLog(@"%s sourceURL = %@", __FUNCTION__, sourceURL);
//
//    // figure out where you want to store the data
//
//    NSLog(@"%s URLsForDirectory=%@", __FUNCTION__, [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]);
//
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsFolder = [paths objectAtIndex:0];  // or paths[0];
//    NSString *filePath = [documentsFolder stringByAppendingPathComponent:filename];
//    NSURL *destinationUrl = [NSURL fileURLWithPath:filePath];
//    NSLog(@"%s destinationUrl = %@", __FUNCTION__, destinationUrl);
//
//    if (![self createFolderForPath:filePath])
//    {
//        return;
//    }
//
//    NSError *error;
//    [fileManager copyItemAtURL:sourceURL toURL:destinationUrl error:&error];
//    if (error)
//        NSLog(@"%s %@", __FUNCTION__, error.localizedDescription);
//}
//
//- (void)downloadFile2:(NSString *)filename fromUrl:(NSString *)urlString
//{
//    NSError *error;
//
//    // download the data
//
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
//
//    if (!data)
//    {
//        NSLog(@"%s unable to download file", __FUNCTION__);
//        return;
//    }
//
//    // figure out where you want to store the data
//
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsFolder = [paths objectAtIndex:0];  // or paths[0];
//    NSString *filePath = [documentsFolder stringByAppendingPathComponent:filename];
//
//    // create the directory if we need to
//
//    if (![self createFolderForPath:filePath])
//    {
//        return;
//    }
//
//    // if file downloaded and folder exists, then write file
//
//    [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
//
//    if (error)
//    {
//        NSLog(@"%s unabled to write file %@", __FUNCTION__, error);
//    }
//}


@end
