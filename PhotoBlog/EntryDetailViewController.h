//
//  EntryDetailViewController.h
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-10-15.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"
#import "ImageDownloader.h"

@interface EntryDetailViewController : UIViewController <ImageDownloaderProtocol>


@property (strong, nonatomic) Entry *entry;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableDictionary *buttonsForPhotoKey;
@end
