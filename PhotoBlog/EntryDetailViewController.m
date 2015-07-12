//
//  EntryDetailViewController.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-10-15.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "EntryDetailViewController.h"
#import "EntryModel.h"
#import "CommentsViewController.h"
#import "ImageDownloader.h"

@implementation EntryDetailViewController
@synthesize entry = _entry;
@synthesize scrollView = _scrollView;
@synthesize buttonsForPhotoKey = _buttonsForPhotoKey;

- (NSMutableDictionary *)buttonsForPhotoKey
{
    if (!_buttonsForPhotoKey) {
        _buttonsForPhotoKey = [[NSMutableDictionary alloc]init];
    }
    return _buttonsForPhotoKey;
}

- (void)barButtonPressed
{
    CommentsViewController *cvc = [[CommentsViewController alloc]init];
    cvc.entry = self.entry;
    [self.navigationController pushViewController:cvc animated:YES];
}


- (id)init
{
    self = [super init];
    if (self) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Comments" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonPressed)];
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = @"Article";
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    //Headline
    UILabel *headlineLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    headlineLabel.numberOfLines = 0;
    headlineLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    headlineLabel.textAlignment = NSTextAlignmentLeft;
    headlineLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.scrollView addSubview:headlineLabel];
    headlineLabel.text = self.entry.headline;
    CGSize maxSize = CGSizeMake(280, 9999);
    CGSize stringSize = [headlineLabel.text sizeWithFont:headlineLabel.font constrainedToSize:maxSize lineBreakMode:headlineLabel.lineBreakMode];
    headlineLabel.frame = CGRectMake(20, 20, self.view.bounds.size.width-40, stringSize.height);
    
    //Location
    UILabel *locationLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    locationLabel.font = [UIFont systemFontOfSize:12.0];
    locationLabel.textAlignment = NSTextAlignmentLeft;
    locationLabel.textColor = [UIColor grayColor];
    [self.scrollView addSubview:locationLabel];
    locationLabel.text = [NSString stringWithFormat:@"%@, %@", self.entry.city, self.entry.country];
    stringSize = [locationLabel.text sizeWithFont:locationLabel.font constrainedToSize:maxSize lineBreakMode:locationLabel.lineBreakMode];
    locationLabel.frame = CGRectMake(20, headlineLabel.bounds.size.height+20,self.view.bounds.size.width-40 , stringSize.height);
    
    
    //Date
    UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    dateLabel.font = [UIFont systemFontOfSize:12.0];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    dateLabel.textColor = [UIColor grayColor];
    [self.scrollView addSubview:dateLabel];
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    dateLabel.text = [formatter stringFromDate:self.entry.datetime];
    stringSize = [dateLabel.text sizeWithFont:dateLabel.font constrainedToSize:maxSize lineBreakMode:dateLabel.lineBreakMode];
    dateLabel.frame = CGRectMake(20, locationLabel.bounds.size.height+headlineLabel.bounds.size.height+20, self.view.bounds.size.width-40, stringSize.height);
    
    //images
    UIScrollView *imageView = [[UIScrollView alloc]initWithFrame:CGRectMake(30,headlineLabel.bounds.size.height+dateLabel.bounds.size.height+locationLabel.bounds.size.height+40,275, 260)];
    imageView.showsHorizontalScrollIndicator = NO;
    imageView.showsVerticalScrollIndicator = NO;
    imageView.clipsToBounds = NO;
    imageView.pagingEnabled = YES;
    if ([self.entry.photoKeys count] == 0) {
        UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 260, 260)];
        but.backgroundColor = [UIColor lightGrayColor];
        [imageView addSubview:but];
    }
    for (int i=1; i <= [self.entry.photoKeys count]; i++) {
        UIButton *but = [[UIButton alloc]initWithFrame:CGRectMake(((i-1)*275), 0, 275, 260)];
        but.imageEdgeInsets = UIEdgeInsetsMake(0, -8, 0, 0);
        UIImage *image = [[EntryModel shareStore] imageForKey:[self.entry.photoKeys objectAtIndex:i-1]];
        if (image) {
            [but setImage:image forState:UIControlStateNormal];
        } else {
            ImageDownloader *imageDownloader = [[ImageDownloader alloc]init];
            [self.buttonsForPhotoKey setObject:but forKey:[self.entry.photoKeys objectAtIndex:i-1]];
            [imageDownloader.delegates addObject: self];
            [imageDownloader downloadImageForKey:[self.entry.photoKeys objectAtIndex:i-1]];
        }
        [imageView addSubview:but];
    }
    imageView.contentSize = CGSizeMake([self.entry.photoKeys count]*275, 260);
    [self.scrollView addSubview:imageView];
    
    
    
    //Text
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(20, headlineLabel.bounds.size.height+dateLabel.bounds.size.height+locationLabel.bounds.size.height+imageView.bounds.size.height+45, self.view.bounds.size.width-40, 1000)];
    textView.font = [UIFont systemFontOfSize:12.0];
    textView.textAlignment = NSTextAlignmentLeft;
    textView.scrollEnabled = NO;
    textView.textColor = [UIColor blackColor];
    [self.scrollView addSubview:textView];
    textView.text = self.entry.text;
    textView.editable = NO;
    [textView sizeToFit];
    [textView layoutIfNeeded];
    
    CGRect frame = CGRectMake(20, headlineLabel.bounds.size.height+dateLabel.bounds.size.height+locationLabel.bounds.size.height+imageView.bounds.size.height+45, self.view.bounds.size.width-40, 0);
    frame.size.height = textView.contentSize.height;
    frame.size.width = textView.bounds.size.width;
    textView.frame = frame;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, headlineLabel.bounds.size.height+dateLabel.bounds.size.height+locationLabel.bounds.size.height+imageView.bounds.size.height+textView.bounds.size.height+65);
    [self.view addSubview:self.scrollView];
}

- (void)imageDownloader:(ImageDownloader *)imageDownloader didFinishDownloadingImageForPhotoKey:(NSString *)photoKey
{
    UIImage *image = [[EntryModel shareStore]imageForKey:photoKey];
    UIButton *but = [self.buttonsForPhotoKey objectForKey:photoKey];
    [UIView beginAnimations:@"flipbutton" context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationTransition:UIViewAnimationCurveEaseIn forView:but cache:YES];
    
    [but setImage:image forState:UIControlStateNormal];
    [UIView commitAnimations];
    
}

@end
