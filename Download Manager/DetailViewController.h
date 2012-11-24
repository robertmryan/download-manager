//
//  DetailViewController.h
//  Download Manager
//
//  Created by Robert Ryan on 11/24/12.
//  Copyright (c) 2012 Robert Ryan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
