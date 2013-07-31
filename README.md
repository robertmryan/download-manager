# Download Manager

--

## Introduction

This is a demonstration of the use of [`NSURLConnection`](https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSURLConnection_Class/Reference/Reference.html), an iOS Cocoa class for loading a URL request, to download files from the Internet. See the [URL Loading System Programming Guide](https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i) for more information about the proper use and capabilities of `NSURLConnection` as well as that of [`NSURLConnectionDataDelegate`](http://developer.apple.com/library/ios/#documentation/Foundation/Reference/NSURLConnectionDataDelegate_protocol/Reference/Reference.html).

Many simple `NSURLConnection` implementations load the entire file into memory while it's being downloaded. This has been designed to avoid that shortcoming, directly streaming the file to persistent storage. Furthermore, as it's streaming the contents to persistent storage, this routine also can inform the calling routine (through a delegate protocol, discussed below) of the progress of the download.

Note, since writing this class, I decided to write a `NSOperation`-based solution, [`DownloadOperation`](https://github.com/robertmryan/download-operation), which is far simpler, employing `NSOperationQueue` to take care of the management of the download operations. I would suggest you look at that solution first, before considering this particular implementation. Or, even better, consider using an actively supported networking library like [AFNetworking](https://github.com/AFNetworking/AFNetworking).

## Class Reference

Please see the [Class Reference](http://robertmryan.github.com/download-manager).

## How to Use

First, you should add the `Download.h`, `Download.m`, `DownloadManager.h` and `DownloadManager.m` files to your project. As always, whenever adding files to your project, make sure the two `.m` files show up under "Compile Sources", in the "Build Phases" section of your target settings.

Second, declare a property for the download manager and, if you want to be informed of the progress of the downloads, conform to the `DownloadManagerDelegateProtocol`:

    #import "DownloadManager.h"

    @interface ViewController () <DownloadManagerDelegateProtocol>
    @property (strong, nonatomic) DownloadManager *downloadManager;
    @end

Third, start the downloads:

    - (void)queueAndStartDownloads
    {
        NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *downloadFolder = [documentsPath stringByAppendingPathComponent:@"downloads"];
            
        // an array of files to be downloaded
        
        NSArray *urlStrings = @[
            @"http://your.web.site.here.com/test/file1.pdf",
            @"http://your.web.site.here.com/test/file2.pdf",
            @"http://your.web.site.here.com/test/file3.pdf",
            @"http://your.web.site.here.com/test/file4.pdf"
        ];
        
        // create download manager instance
        
        self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
        
        // queue the files to be downloaded
        
        for (NSString *urlString in urlStrings)
        {
            NSString *downloadFilename = [downloadFolder stringByAppendingPathComponent:[urlString lastPathComponent]];
            NSURL *url = [NSURL URLWithString:urlString];
            
            [self.downloadManager addDownloadWithFilename:downloadFilename URL:url];
        }

        // start the download manager
                
        [self.downloadManager start];
    }

Fourth, if you want to be informed when the downloads complete, define a `didFinishLoadingAllForManager` method

    - (void)didFinishLoadingAllForManager:(DownloadManager *)downloadManager
    {
        // all downloads successful
    }

Fifth, if you want to be informed of the success or failure of individual downloads, define

    - (void)downloadManager:(DownloadManager *)downloadManager downloadDidFinishLoading:(Download *)download;
    {
        // download failed
        // filename is retrieved from `download.filename`
    }

    - (void)downloadManager:(DownloadManager *)downloadManager downloadDidFail:(Download *)download;
    {
        // download failed
        // filename is retrieved from `download.filename`
    }
    
Sixth, and finally, if you want to be informed as the download is in progress, you can use

    - (void)downloadManager:(DownloadManager *)downloadManager downloadDidReceiveData:(Download *)download;
    {
        // download failed
        // filename is retrieved from `download.filename`
        // the bytes downloaded thus far is `download.progressContentLength`
        // if the server reported the size of the file, it is returned by `download.expectedContentLength`
    }

By the way, regarding `download.expectedContentLength`, it should be noted that Apple reports that this is not entirely trustworthy:

> Some protocol implementations report the content length as part of the response, but not all protocols guarantee to deliver that amount of data. Clients should be prepared to deal with more or less data.

## Example

To demonstrate the use of these utility classes, this demonstration includes the following classes:

- `MasterViewController` is a `UITableViewController` subclass that uses `DownloadManager` to download a series of files from the Internet and to put the resulting files in a folder in the iOS device's `Documents` folder;
- `DownloadCell` is a `UITableViewCell` subclass that defines the three controls (a `UIActivityIndicatorView`, a `UIProgressView` and a `UILabel`) used by `MasterViewController`
- `AppDelegate` is just the standard app delegate

--

If you have any questions, do not hesitate to contact me at:

Rob Ryan
robert.ryan@mindspring.com

24 November 2012

