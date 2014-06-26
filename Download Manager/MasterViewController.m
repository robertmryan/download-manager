//
//  MasterViewController.m
//  Download Manager
//
//  Created by Robert Ryan on 11/24/12.
//  Copyright (c) 2012 Robert Ryan.
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

#import "MasterViewController.h"

#import "DownloadManager.h"
#import "DownloadCell.h"

@interface MasterViewController () <DownloadManagerDelegate>

@property (strong, nonatomic) DownloadManager *downloadManager;
@property (strong, nonatomic) NSDate *startDate;
@property (nonatomic) NSInteger downloadErrorCount;
@property (nonatomic) NSInteger downloadSuccessCount;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self queueAndStartDownloads];
}

- (void)queueAndStartDownloads
{
    
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *downloadFolder = [documentsPath stringByAppendingPathComponent:@"downloads"];
        
#warning replace URLs with the names of the files and the URL you want to download them from

    // an array of files to be downloaded
    
    NSArray *urlStrings = @[@"http://www.yourwebsitehere.com/test/file1.pdf",
                            @"http://www.yourwebsitehere.com/test/file2.pdf",
                            @"http://www.yourwebsitehere.com/test/file3.pdf",
                            @"http://www.yourwebsitehere.com/test/file4.pdf"];
    
    // create download manager instance
    
    self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    
    // queue the files to be downloaded
    
    for (NSString *urlString in urlStrings)
    {
        NSString *downloadFilename = [downloadFolder stringByAppendingPathComponent:[urlString lastPathComponent]];
        NSURL *url = [NSURL URLWithString:urlString];
        
        [self.downloadManager addDownloadWithFilename:downloadFilename URL:url];
    }
    
    // I've added a cancel button to my user interface, so now that downloads have started, let's enable that button
    
    self.cancelButton.enabled = YES;
    self.startDate = [NSDate date];
}

#pragma mark - DownloadManager Delegate Methods

// optional method to indicate completion of all downloads
//
// In this view controller, display message

- (void)didFinishLoadingAllForManager:(DownloadManager *)downloadManager
{
    NSString *message;
    
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.startDate];
    
    self.cancelButton.enabled = NO;
    
    if (self.downloadErrorCount == 0)
        message = [NSString stringWithFormat:@"%d file(s) downloaded successfully. The files are located in the app's Documents folder on your device/simulator. (%.1f seconds)", self.downloadSuccessCount, elapsed];
    else
        message = [NSString stringWithFormat:@"%d file(s) downloaded successfully. %d file(s) were not downloaded successfully. The files are located in the app's Documents folder on your device/simulator. (%.1f seconds)", self.downloadSuccessCount, self.downloadErrorCount, elapsed];
    
    [[[UIAlertView alloc] initWithTitle:nil
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

// optional method to indicate that individual download completed successfully
//
// In this view controller, I'll keep track of a counter for entertainment purposes and update
// tableview that's showing a list of the current downloads.

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFinishLoading:(Download *)download;
{
    self.downloadSuccessCount++;
    
    [self.tableView reloadData];
}

// optional method to indicate that individual download failed
//
// In this view controller, I'll keep track of a counter for entertainment purposes and update
// tableview that's showing a list of the current downloads.

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFail:(Download *)download;
{
    NSLog(@"%s %@ error=%@", __FUNCTION__, download.filename, download.error);
    
    self.downloadErrorCount++;
    
    [self.tableView reloadData];
}

// optional method to indicate progress of individual download
//
// In this view controller, I'll update progress indicator for the download.

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidReceiveData:(Download *)download;
{
    for (NSInteger row = 0; row < [downloadManager.downloads count]; row++)
    {
        if (download == downloadManager.downloads[row])
        {
            [self updateProgressViewForIndexPath:[NSIndexPath indexPathForRow:row inSection:0] download:download];
            break;
        }
    }
}

#pragma mark - Table View delegate and data source methods

// our table view will simply display a list of files being downloaded

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.downloadManager.downloads count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DownloadCell";
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Download *download = self.downloadManager.downloads[indexPath.row];
    
    // the name of the file
    
    cell.filenameLabel.text = [download.filename lastPathComponent];
    
    if (download.isDownloading)
    {
        // if we're downloading a file turn on the activity indicator
        
        if (!cell.activityIndicator.isAnimating)
            [cell.activityIndicator startAnimating];
        
        cell.activityIndicator.hidden = NO;
        cell.progressView.hidden = NO;

        [self updateProgressViewForIndexPath:indexPath download:download];
    }
    else
    {
        // if not actively downloading, no spinning activity indicator view nor file download progress view is needed
        
        [cell.activityIndicator stopAnimating];
        cell.activityIndicator.hidden = YES;
        cell.progressView.hidden = YES;
    }
    
    return cell;
}

#pragma mark - Table view utility methods

- (void)updateProgressViewForIndexPath:(NSIndexPath *)indexPath download:(Download *)download
{
    DownloadCell *cell = (DownloadCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    // if the cell is not visible, we can return
    
    if (!cell)
        return;
    
    if (download.expectedContentLength >= 0)
    {
        // if the server was able to tell us the length of the file, then update progress view appropriately
        // to reflect what % of the file has been downloaded
        
        cell.progressView.progress = (double) download.progressContentLength / (double) download.expectedContentLength;
    }
    else
    {
        // if the server was unable to tell us the length of the file, we'll change the progress view, but
        // it will just spin around and around, not really telling us the progress of the complete download,
        // but at least we get some progress update as bytes are downloaded.
        //
        // This progress view will just be what % of the current megabyte has been downloaded
        
        cell.progressView.progress = (double) (download.progressContentLength % 1000000L) / 1000000.0;
    }
}

#pragma mark - IBAction methods

- (IBAction)tappedCancelButton:(id)sender
{
    [self.downloadManager cancelAll];
}

@end
