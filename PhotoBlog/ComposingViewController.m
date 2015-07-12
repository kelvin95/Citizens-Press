//
//  ComposingViewController.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-26.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "ComposingViewController.h"
#import <CoreLocation/CoreLocation.h>
#define PLACEHOLDER @"Write something here..."
#define HEADLINEPLACEHOLDER @"Write headline here..."
#define ROOTURL @"http://testphotos95.appspot.com/"
#import <QuartzCore/QuartzCore.h>

@interface ComposingViewController ()

@end

@implementation ComposingViewController
@synthesize scrollView = _scrollView;
@synthesize photos = _photos;
@synthesize location = _location;
@synthesize locationManager = _locationManager;
@synthesize headlineText = _headlineText;
@synthesize descriptionText = _descriptionText;


- (NSString *)headlineText
{
    if (!_headlineText) {
        _headlineText = [NSString string];
    }
    return _headlineText;
}

- (NSString *)descriptionText
{
    if (!_descriptionText) {
        _descriptionText = [NSString string];
    }
    return _descriptionText;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        [_locationManager setDesiredAccuracy: kCLLocationAccuracyBest];
        [_locationManager setDelegate:self];
    }
    return _locationManager;
}

- (NSMutableArray *)photos
{
    if (!_photos) {
        _photos = [[NSMutableArray alloc]init];
    }
    return _photos;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGSize size = [image size];
    CGRect rect = CGRectMake(0, (size.height-size.width)/2 ,size.width, size.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(260,260), NO, 0.0);
    [img drawInRect:CGRectMake(0, 0, 260, 260)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage * newImageForUpload = [[UIImage alloc] initWithCGImage: newImage.CGImage
                                                         scale: 1.0
                                                   orientation: UIImageOrientationRight];
    //NSLog(@"%@", newImage);
    [self.photos addObject:newImageForUpload];
    //[self.photos addObject:newImage];
    [self viewWillAppear:YES];
}

- (void)addPhotoButtonClicked
{
    [self.headlineTextView resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    [picker setDelegate:self];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [picker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (NSData *)encodeDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *parts = [[NSMutableArray alloc]init];
    for (NSString *key in dictionary) {
        NSString *encodedValue = [[dictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *part = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)onCancel
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.location = [locations objectAtIndex:0];
}

- (void)postArticleToServer: (NSDictionary *)arguments photos:(NSArray *)photos
{
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@Compose", ROOTURL]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[self encodeDictionary:arguments]];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] && !error) {
                                   NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil];
                                   //NSLog(@"%@", [dictionary objectForKey:@"articleKey"]);
                                   for (UIImage *image in photos) {
                                       NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@Photo/%@", ROOTURL, [dictionary objectForKey:@"articleKey"]]];
                                       NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
                                       [urlRequest setHTTPMethod:@"POST"];
                                       NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
                                       [urlRequest setHTTPBody:imageData];
                                       [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:nil];
                                   }
                                   
                               } else {
                                   UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Could not post"
                                                                                     message:@"Please check your 3G or Wifi connection."
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil];
                                   [message show];
                               }
                           }];

}

- (void)sendArticle
{

    if ([self.headlineTextView.text length] == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Headline"
                                                          message:@"Please add a headline before posting."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
    } else if ([self.photos count] == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Photos"
                                                          message:@"Please add a photo before posting."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
    } else if ([self.descriptionTextView.text length] == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Description"
                                                          message:@"Please add a description before posting."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    NSMutableDictionary *arguments = [NSMutableDictionary dictionary];
    [arguments setObject:self.descriptionTextView.text forKey:@"text"];
    [arguments setObject:self.headlineTextView.text forKey:@"headline"];
    if ([CLLocationManager locationServicesEnabled]) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
    
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *country = [NSString stringWithFormat:@"%@", placemark.country];
            [arguments setObject:country forKey:@"country"];
            [arguments setObject:[NSString stringWithFormat:@"%@",placemark.locality] forKey:@"city"];
            [self postArticleToServer:arguments photos:self.photos];
            }];
        }
    } else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Locations Services Not Enabled"
                                                          message:@"Please enable location services in Settings before posting."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)addPhotosToScrollView
{
    CGFloat rectHeight = 65.0f;
    //[self.scrollViewContentView removeFromSuperview];
    for (int i=0; i<[self.photos count]; i++) {
        UIImage *image = [self.photos objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(5+((i+1)*65), 5, 60, 60)];
        UIGraphicsBeginImageContext(CGSizeMake(60,60));
        [image drawInRect:CGRectMake(0, 0, 60, 60)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        imageView.image = newImage;
        [self.scrollViewContentView addSubview:imageView];
        rectHeight += 65.0f;
    }
    if (rectHeight <= self.view.bounds.size.width) {
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width+1, self.scrollView.frame.size.height);
    } else {
        self.scrollView.contentSize = CGSizeMake(rectHeight, self.scrollView.frame.size.height);
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FormsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FormsCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    }
    if ([indexPath row] == 0) {
        UITextView *labelTextView = [[UITextView alloc]initWithFrame:CGRectMake(5, 0, 295, 30)];
        labelTextView.userInteractionEnabled = NO;
        labelTextView.text = @"Headline";
        labelTextView.font = [UIFont systemFontOfSize:14.0];
        labelTextView.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:labelTextView];
        
        UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(5, 0, 295, 30)];
        textView.keyboardAppearance = UIKeyboardAppearanceDark;
        textView.clipsToBounds = NO;
        textView.font = [UIFont systemFontOfSize:14.0];
        textView.delegate = self;
        textView.scrollEnabled = NO;
        self.headlineTextView = textView;
        //textView.clipsToBounds = NO;
        if ([self.headlineText length]) {
            textView.backgroundColor = [UIColor whiteColor];
            textView.text = self.headlineText;
        } else {
            textView.backgroundColor = [UIColor clearColor];
        }
        [self.headlineTextView becomeFirstResponder];
        [cell.contentView addSubview:textView];
        
    } else if ([indexPath row] == 1) {
        UITextView *labelTextView = [[UITextView alloc]initWithFrame:CGRectMake(5, 0, 295, self.tableView.bounds.size.height - 30)];
        labelTextView.userInteractionEnabled = NO;
        labelTextView.text = @"Description";
        labelTextView.font = [UIFont systemFontOfSize:14.0];
        labelTextView.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:labelTextView];
        
        
        //CGFloat height = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
        //NSLog(@"Cell%f", height);
        UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(5, 0, 295, self.tableView.bounds.size.height - 30)];
        textView.keyboardAppearance = UIKeyboardAppearanceDark;
        textView.clipsToBounds = NO;
        textView.delegate = self;
        textView.font = [UIFont systemFontOfSize:14.0];
        if ([self.descriptionText length]) {
            textView.backgroundColor = [UIColor whiteColor];
            textView.text = self.descriptionText;
        } else {
            textView.backgroundColor = [UIColor clearColor];
        }
        self.descriptionTextView = textView;
        [cell.contentView addSubview:textView];
    }
    return cell;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"%@", text);
    if (textView == self.headlineTextView) {
        if ([[self.headlineTextView.text stringByAppendingString:text] sizeWithFont:self.headlineTextView.font].width > self.headlineTextView.bounds.size.width-25) {
            return NO;
        } else if ([text isEqualToString:@"\n"]) {
            return NO;
        }
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] != 0) {
        textView.backgroundColor = [UIColor whiteColor];
    } else {
        textView.backgroundColor = [UIColor clearColor];
    }
    NSLog(@"%@ %@", self.scrollViewContentView, self.scrollView);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.headlineText = self.headlineTextView.text;
    self.descriptionText = self.descriptionTextView.text;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0) {
        return 30;
        
    } else if ([indexPath row] == 1) {
        //NSLog(@"Cell%f", self.tableView.bounds.size.height - 30);
        return self.tableView.bounds.size.height - 30;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*
    for (UIView *subview in self.view.subviews) {
        [subview removeFromSuperview];
    }
    */
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 70)];
    scrollView.backgroundColor = [UIColor blackColor];
    scrollView.contentSize = CGSizeMake(321, 70);
    [self.view addSubview:scrollView];

    UIView *scrollViewContentView = [[UIView alloc]initWithFrame:CGRectMake(scrollView.bounds.origin.x, scrollView.bounds.origin.y, scrollView.frame.size.width+1, 70)];
    UIButton *addPhotoButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 60, 60)];
    [addPhotoButton setImage:[UIImage imageNamed:@"addButton.png"] forState:UIControlStateNormal];
    [addPhotoButton addTarget:self action:@selector(addPhotoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [scrollViewContentView addSubview:addPhotoButton];
    [scrollView addSubview:scrollViewContentView];
    scrollView.contentSize = scrollViewContentView.frame.size;
    
    self.scrollView = scrollView;
    self.scrollViewContentView = scrollViewContentView;

    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(5, scrollView.frame.size.height+scrollView.frame.origin.y, self.view.bounds.size.width-10, self.view.bounds.size.height - 286 - 64) style:UITableViewStylePlain];
    tableView.layer.cornerRadius = 5;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    UIView *bView = [[UIView alloc]initWithFrame:tableView.frame];
    bView.backgroundColor = [UIColor blackColor];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancel)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendArticle)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(sendArticle)];
    
    [self addPhotosToScrollView];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}


@end
