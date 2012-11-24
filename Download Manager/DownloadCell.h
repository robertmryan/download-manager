//
//  DownloadCell.h
//  TestingPlatform
//
//  Created by Robert Ryan on 11/21/12.
//
//

#import <UIKit/UIKit.h>

@interface DownloadCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *filenameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@end
