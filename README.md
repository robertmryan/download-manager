# Download Manager

--

## Introduction

This is a demonstration of the use of [`NSURLConnection`](https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSURLConnection_Class/Reference/Reference.html), an iOS Cocoa class for loading a URL request, to download files from the Internet. See the [URL Loading System Programming Guide](https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i) for more information about the proper use and capabilities of `NSURLConnection` as well as that of [`NSURLConnectionDataDelegate`](http://developer.apple.com/library/ios/#documentation/Foundation/Reference/NSURLConnectionDataDelegate_protocol/Reference/Reference.html).

Many simple `NSURLConnection` implementations load the entire file into memory while it's being downloaded. This has been designed to avoid that shortcoming, directly streaming the file to persistent storage. Furthermore, as it's streaming the contents to persistent storage, this routine also can inform the calling routine (through a delegate protocol, discussed below) of the progress of the download.

## Classes

There are two key classes in this project:

### DownloadManager

While the `Download` class (below) will download individual files, the `DownloadManager` allows you to coordinate multiple downloads. If you use this `DownloadManager` class, you do not have to interact directly with the `Download` class (other than optionally inquiring about the progress of the downloads in the `DownloadManagerDelegateProtocol` methods).

##### Delegate Protocol

The `DownloadManager` class defines a delegate protocol, `DownloadManagerDelegateProtocol`, to inform the `delegate` regarding the success or failure of the downloads. The first informs the delegate regarding the completion of all queued downloads:

- The `didFinishLoadingAllForManager` method informs the delegate that all downloads have finished (whether successfully or unsuccessfully)

The other three methods inform the delegate regarding the progress of the individual downloads:

- The `downloadManager:downloadDidFinishLoading:` informs the delegate that the download finished successfully;
- The `downloadManager:downloadDidFail:` informs the delegate that the download failed for some reason; and
- The `downloadManager:downloadDidReceiveData:` is called to inform the delegate of the progress of a download as it proceeds.

##### Instance Methods

- The `initWithDelegate:` method creates the `DownloadManager` object;
- The `addDownloadWithFilename:URL:` method queue a download and if possible, initiates that download;
- The `start` method initiates the downloads; and
- The `cancelAll` method cancels all downloads, both those in progress and those queued to be processed.

##### Properties

The `DownloadManager` has the following properties:

- The `downloads` array is a list of `Download` requests that are queued and/or in progress (you can inquire the `Download` properties of the individual entries to determine their status);
- The `maxConcurrentDownloads` lets you dictate how many individual downloads may operate concurrently. This defaults to `4`.

### Download

The `Download` is a class to download a single file using `NSURLConnection`. Generally you will not interact directly with this class, but rather just employ the `DownloadManager` class discussed above.

##### Delegate Protocol

The `Download` class defines a delegate protocol, `DownloadDelegateProtocol`, to inform the `delegate` regarding the success or failure of a download. There are three relevant methods:

- The `downloadDidFinishLoading:` informs the delegate that the individual download finished successfully;
- The `downloadDidFail:` informs the delegate that the download failed for some reason; and
- The `downloadDidReceiveData:` is called to inform the delegate of the progress of a download as it proceeds.

##### Instance Methods

- The `initWithFilename:URL:delegate:` method creates the `Download` object; and
- The `start` method initiates the actual download.
- The `cancel` method cancels the current download. Upon successful cancellation, `downloadDidFail` will be called.

##### Properties

The `Download` class lets you inquire regarding the progress of a download using the following properties:

- The `downloading` boolean will inform you whether this download is in progress or not;
- The `expectedContentLength` property will tell you how large the file is (if the server told us; it's a negative number otherwise);
- The `progressContentLength` property will tell you how far along in that download we have progress; and
- The `error` property contains any `NSError` that was generated (if any).

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

