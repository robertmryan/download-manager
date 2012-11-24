# Download Manager

--

## Introduction

This is a demonstration of the use of [`NSURLConnection`](https://developer.apple.com/library/ios/#documentation/Cocoa/Reference/Foundation/Classes/NSURLConnection_Class/Reference/Reference.html), an iOS Cocoa class for loading a URL request, to download files from the Internet. See the [URL Loading System Programming Guide](https://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i) for more information about the proper use and capabilities of `NSURLConnection`.

This was created to answer a question on Stack Overflow. Please refer to that [question](http://stackoverflow.com/questions/13363858/ios-copy-file-to-new-folder-in-documents-directory-not-working/13364673#13364673) for further context.

## Classes

There are two key classes in this project:

### Download

The `Download` is a class to download a single file using `NSURLConnection`. Note, frequently apps will not use this class directly, but rather just employ the `DownloadManager` class discussed below.

##### Delegate Protocol

The `Download` class defines a delegate protocol, `DownloadDelegateProtocol`, to inform the `delegate` regarding the success or failure of a download. There are three relevant methods:

- The `downloadDidFinishLoading:` informs the delegate that the download finished successfully;
- The `downloadDidFail:` informs the delegate that the download failed for some reason; and
- The `downloadDidReceiveData:` is called to inform the delegate of the progress of a download as it proceeds.

##### Instance Methods

- The `initWithFilename:URL:delegate:` method creates the `Download` object; and
- The `download` method initiates the actual download.

##### Properties

The `Download` class lets you inquire regarding the progress of a download using the following properties:

- The `downloading` boolean will inform you whether this download is in progress or not;
- The `expectedContentLength` property will tell you how large the file is (if the server told us; it's a negative number otherwise);
- The `progressContentLength` property will tell you how far along in that download we have progress; and
- The `error` property contains any `NSError` that was generated (if any).

### DownloadManager

While the `Download` class will download individual files, the `DownloadManager` allows you to coordinate multiple downloads. If you use this `DownloadManager` class, you do not have to interact directly with the `Download` class (other than optionally inquiring about the progress of the downloads in the `DownloadManagerDelegateProtocol` methods).

##### Delegate Protocol

- The `DownloadManager` class defines a delegate protocol, `DownloadManagerDelegateProtocol`, to inform the `delegate` regarding the success or failure of the downloads:

- The `downloadManager:downloadDidFinishLoading:` informs the delegate that the download finished successfully;
- The `downloadManager:downloadDidFail:` informs the delegate that the download failed for some reason; and
- The `downloadManager:downloadDidReceiveData:` is called to inform the delegate of the progress of a download as it proceeds.

##### Instance Methods

- The `initWithDelegate:` method creates the `DownloadManager` object; and
- The `addDownloadWithFilename:URL:` method adds a download to the list of downloads.

##### Properties

The `DownloadManager` has the following properties:

- The `downloads` array is a list of `Download` requests that are queued and/or in progress (you can inquire the `Download` properties of the individual entries to determine their status);
- The `maxConcurrentDownloads` lets you dictate how many individual downloads may operate concurrently. This defaults to `4`.

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

