//
//  CommentsViewController.h
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-14.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"

@interface CommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) Entry *entry;
@property (strong, nonatomic) NSMutableArray *arrayOfComments;

@end
