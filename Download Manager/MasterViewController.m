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

@interface MasterViewController () <DownloadManagerDelegateProtocol>
{
    NSInteger downloadErrorCount;
    NSInteger downloadSuccessCount;
}

@property (strong, nonatomic) DownloadManager *downloadManager;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self queueAndStartDownloads];
}

- (void)queueAndStartDownloads
{
    
#warning replace filenames and URL with the names of the files and the URL you want to download them from 
    
    NSArray *filenames = @[
        @"file1.zip",
        @"file2.zip"
    ];
    
    NSURL *baseUrl = [NSURL URLWithString:@"http://your-url-here.com/files"];
    
    NSString *documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *downloadFolder = [documentsPath stringByAppendingPathComponent:@"downloads"];

    self.downloadManager = [[DownloadManager alloc] initWithDelegate:self];
    
    for (NSString *filename in filenames)
    {
        NSString *downloadFilename = [downloadFolder stringByAppendingPathComponent:filename];
        NSURL *finalUrl = [baseUrl URLByAppendingPathComponent:[filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [self.downloadManager addDownloadWithFilename:downloadFilename URL:finalUrl];
    }
}

- (void)alertUserIfDownloadsDone
{
    if ([self.downloadManager.downloads count] == 0)
    {
        NSString *message;
        if (downloadErrorCount == 0)
            message = [NSString stringWithFormat:@"%d file(s) downloaded successfully. The files are located in the app's Documents folder on your device/simulator.", downloadSuccessCount];
        else
            message = [NSString stringWithFormat:@"%d file(s) downloaded successfully. %d file(s) were not downloaded successfully. The files are located in the app's Documents folder on your device/simulator.", downloadSuccessCount, downloadErrorCount];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - DownloadManager Delegate Methods

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFinishLoading:(Download *)download;
{
    downloadSuccessCount++;
    
    [self.tableView reloadData];
    
    [self alertUserIfDownloadsDone];
}

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidFail:(Download *)download;
{
    NSLog(@"%s %@ error=%@", __FUNCTION__, download.filename, download.error);
    
    downloadErrorCount++;
    
    [self.tableView reloadData];

    [self alertUserIfDownloadsDone];
}

- (void)downloadManager:(DownloadManager *)downloadManager downloadDidReceiveData:(Download *)download;
{
    if (download.expectedContentLength >= 0)
    {
        for (NSInteger row = 0; row < [downloadManager.downloads count]; row++)
        {
            if (download == downloadManager.downloads[row])
            {
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
}

#pragma mark - Table View

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
    
    cell.filenameLabel.text = [download.filename lastPathComponent];
    if (download.isDownloading)
    {
        [cell.activityIndicator startAnimating];
        cell.activityIndicator.hidden = NO;
        if (download.expectedContentLength >= 0)
        {
            cell.progressView.hidden = NO;
            cell.progressView.progress = (double) download.progressContentLength / (double) download.expectedContentLength;
        }
        else
        {
            cell.progressView.hidden = YES;
        }
    }
    else
    {
        [cell.activityIndicator stopAnimating];
        cell.activityIndicator.hidden = YES;
        cell.progressView.hidden = YES;
    }
    
    return cell;
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSDate *object = _objects[indexPath.row];
//        [[segue destinationViewController] setDetailItem:object];
//    }
//}

@end
