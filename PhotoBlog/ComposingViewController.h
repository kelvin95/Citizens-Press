//
//  ComposingViewController.h
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-26.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ComposingViewController : UIViewController <UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *scrollViewContentView;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITextView *headlineTextView;
@property (strong, nonatomic) UITextView *descriptionTextView;

@property (strong, nonatomic) NSString *headlineText;
@property (strong, nonatomic) NSString *descriptionText;


@end
