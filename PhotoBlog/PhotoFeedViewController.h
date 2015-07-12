//
//  PhotoFeedViewController.h
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-10-11.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"


@interface PhotoFeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ImageDownloaderProtocol>


@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *view;
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSMutableDictionary *indexPathsOfPhotoKeys;

@end
