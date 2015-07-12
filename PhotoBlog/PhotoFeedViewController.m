//
//  PhotoFeedViewController.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-10-11.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "PhotoFeedViewController.h"
#import "Entry.h"
#import <dispatch/dispatch.h>
#import "EntryModel.h"
#import "EntryDetailViewController.h"
#import "ImageDownloader.h"
#import "ComposingViewController.h"

#define HEADLINETAG 1
#define DATETAG 2
#define IMAGETAG 3
#define LOADTAG 4
#define DATELOADEDTAG 5
#define LOADMORETAG 6
#define LOCATIONTAG 7

@interface PhotoFeedViewController ()

@end

@implementation PhotoFeedViewController

@synthesize tableView = _tableView;
@synthesize isLoading = _isLoading;
@synthesize indexPathsOfPhotoKeys = _indexPathsOfPhotoKeys;

#pragma mark - PROPERTY SETTERS AND GETTERS

- (NSMutableDictionary *)indexPathsOfPhotoKeys
{
    if (!_indexPathsOfPhotoKeys) {
        _indexPathsOfPhotoKeys = [[NSMutableDictionary alloc]init];
    }
    return _indexPathsOfPhotoKeys;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 300;
        
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, -480, self.view.bounds.size.width, 480)];
        headerView.backgroundColor = [UIColor lightGrayColor];
        UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 420, self.view.bounds.size.width, 25)];
        loadingLabel.text = @"Loading...";
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.backgroundColor = [UIColor clearColor];
        loadingLabel.tag = LOADTAG;
        loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0];
        [headerView addSubview:loadingLabel];
                
        UILabel *dateLoadedLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 440, self.view.bounds.size.width, 25)];
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"hh:mm MMM d yyyy" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        dateLoadedLabel.text = [NSString stringWithFormat:@"Last updated: %@", [formatter stringFromDate:[NSDate new]]];
        dateLoadedLabel.backgroundColor = [UIColor clearColor];
        dateLoadedLabel.font = [UIFont systemFontOfSize:13.0];
        dateLoadedLabel.textAlignment = NSTextAlignmentCenter;
        dateLoadedLabel.tag = DATELOADEDTAG;
        [headerView addSubview:dateLoadedLabel];
        
        [_tableView addSubview:headerView];
        
    }
    return _tableView;
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    UILabel *loadingLabel = (UILabel *)[self.tableView viewWithTag:LOADTAG];
    if (_isLoading){
        [UIView beginAnimations:nil context:nil];
        loadingLabel.text = @"Loading...";
        [self.tableView setContentInset:UIEdgeInsetsMake(80, 0, 0, 0)];
        [self.tableView setContentOffset:CGPointMake(0, -80) animated:YES];
        [UIView commitAnimations];
        [[EntryModel shareStore] reloadEntriesFromWebWithCompletion:^(NSError *error) {
            NSLocale *locale = [NSLocale currentLocale];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"hh:mm MMM d yyyy" options:0 locale:locale];
            [formatter setDateFormat:dateFormat];
            [formatter setLocale:locale];
            ((UILabel *)[self.tableView viewWithTag:DATELOADEDTAG]).text = [NSString stringWithFormat:@"Last updated: %@", [formatter stringFromDate:[NSDate new]]];
            self.isLoading = NO;
            [self.tableView reloadData];
        }];
    } else {
        [UIView beginAnimations:nil context:nil];
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        loadingLabel.text = @"Pull down to refresh...";
        [UIView commitAnimations];
    }
    
}

#pragma mark - SCROLLVIEW DELEGATE METHODS
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UILabel *loadingLabel = (UILabel *)[self.tableView viewWithTag:LOADTAG];
    if (!self.isLoading) {
        if (scrollView.contentOffset.y < -80) {
            loadingLabel.text = @"Release to refresh...";
        } else {
            loadingLabel.text = @"Pull down to refresh...";
        }
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.isLoading) {
        if (scrollView.contentOffset.y < -80) {
            self.isLoading = YES;
        } else {
            self.isLoading = NO;
        }
    }
}

#pragma mark - DELEGATE METHODS

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EntryDetailViewController *edvc = [[EntryDetailViewController alloc]init];
    edvc.entry = [[[EntryModel shareStore]arrayOfEntries] objectAtIndex:indexPath.row];
    //edvc.title = edvc.entry.headline;
    [self.navigationController pushViewController:edvc animated:YES];
    self.title = @"";
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *photoCell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [photoCell viewWithTag:HEADLINETAG].bounds.size.height+[photoCell viewWithTag:DATETAG].bounds.size.height+[photoCell viewWithTag:LOCATIONTAG].bounds.size.height+[photoCell viewWithTag:IMAGETAG].bounds.size.height+45;
}



#pragma mark - DATASOURCE METHODS

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *photoCell = [self.tableView dequeueReusableCellWithIdentifier:@"photoCell"];
    if (!photoCell) {
        photoCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"photoCell"];
        photoCell.contentView.backgroundColor = [UIColor whiteColor];
        photoCell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        UILabel *headlineLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        headlineLabel.tag = HEADLINETAG;
        headlineLabel.numberOfLines = 0;
        headlineLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        headlineLabel.textAlignment = NSTextAlignmentLeft;
        headlineLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [photoCell.contentView addSubview:headlineLabel];
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        dateLabel.tag = DATETAG;
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        dateLabel.textColor = [UIColor grayColor];
        [photoCell.contentView addSubview:dateLabel];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        imageView.tag = IMAGETAG;
        imageView.backgroundColor = [UIColor lightGrayColor];
        [photoCell.contentView addSubview:imageView];
        
        UILabel *locationLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        locationLabel.tag = LOCATIONTAG;
        locationLabel.font = [UIFont systemFontOfSize:12.0];
        locationLabel.textAlignment = NSTextAlignmentLeft;
        locationLabel.textColor = [UIColor grayColor];
        [photoCell.contentView addSubview:locationLabel];
        
        
    }
    
    Entry *entry = [[[EntryModel shareStore] arrayOfEntries] objectAtIndex:[indexPath row]];
    if (!entry) {
        return photoCell;
    }
    
    UILabel *headlineLabel = ((UILabel *)[photoCell viewWithTag:HEADLINETAG]);
    headlineLabel.text = entry.headline;
    CGSize maxSize = CGSizeMake(280, 9999);
    CGSize stringSize = [headlineLabel.text sizeWithFont:headlineLabel.font constrainedToSize:maxSize lineBreakMode:headlineLabel.lineBreakMode];
    headlineLabel.frame = CGRectMake(20, 20, self.tableView.bounds.size.width-40, stringSize.height);
    
    UILabel *locationLabel = ((UILabel *)[photoCell viewWithTag:LOCATIONTAG]);
    locationLabel.text = [NSString stringWithFormat:@"%@, %@", entry.city, entry.country];
    stringSize = [locationLabel.text sizeWithFont:locationLabel.font constrainedToSize:maxSize lineBreakMode:locationLabel.lineBreakMode];
    locationLabel.frame = CGRectMake(20, headlineLabel.bounds.size.height+20,self.tableView.bounds.size.width-40 , stringSize.height);
    
    
    UILabel *dateLabel = ((UILabel *)[photoCell viewWithTag:DATETAG]);
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    dateLabel.text = [formatter stringFromDate:entry.datetime];
    stringSize = [dateLabel.text sizeWithFont:dateLabel.font constrainedToSize:maxSize lineBreakMode:dateLabel.lineBreakMode];
    dateLabel.frame = CGRectMake(20, locationLabel.bounds.size.height+headlineLabel.bounds.size.height+20, self.tableView.bounds.size.width-40, stringSize.height);

    
    UIImageView *imageView = ((UIImageView *)[photoCell viewWithTag:IMAGETAG]);
    //NSLog(@"%i%@", [indexPath row], entry.photoKeys);
    
    if ([entry.photoKeys count]) {
        [self.indexPathsOfPhotoKeys setObject:indexPath forKey:[entry.photoKeys objectAtIndex:0]];
        UIImage *image = [[EntryModel shareStore]imageForKey: [entry.photoKeys objectAtIndex:0]];
        if (image) {
            imageView.image = image;
        } else {
            ImageDownloader *imageDownloader = [[ImageDownloader alloc]init];
            [imageDownloader.delegates addObject: self];
            imageDownloader.indexPath = indexPath;
            [imageDownloader downloadImageForKey:[entry.photoKeys objectAtIndex:0]];
        }
    } else {
        imageView.image = nil;
    }
    imageView.frame = CGRectMake(30, headlineLabel.bounds.size.height+25+dateLabel.bounds.size.height+locationLabel.bounds.size.height, self.tableView.bounds.size.width-60, self.tableView.bounds.size.width-60);
    return photoCell;
}

- (void)imageDownloader:(ImageDownloader *)imageDownloader didFinishDownloadingImageForPhotoKey:(NSString *)photoKey
{
    NSIndexPath *indexPath = [self.indexPathsOfPhotoKeys objectForKey:photoKey];
    UIImageView *imageView = (UIImageView *)[[self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:IMAGETAG];
    imageView.image = [[EntryModel shareStore]imageForKey:photoKey];
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[EntryModel shareStore] arrayOfEntries] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - BUTTON ACTIONS
- (void)onCompose
{
    ComposingViewController *cvc = [[ComposingViewController alloc]init];
    cvc.title = @"Compose";
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:cvc];
    navController.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:navController animated:YES completion:nil];
    
}



#pragma mark - VIEW CONTROLLER LIFECYCLE

- (id)init
{
    self = [super init];
    if (self) {
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.view = [[UIView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isLoading = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title = @"Citizen Press";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onCompose)];
    //dispatch_queue_t imageQueue = dispatch_queue_create("image", NULL);
    //dispatch_async(imageQueue, ^{
    //self.isLoading = YES;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[[EntryModel shareStore] dictionaryOfPhotos]removeAllObjects];
}

@end
