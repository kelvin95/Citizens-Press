//
//  ComposeCommentViewController.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-28.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "ComposeCommentViewController.h"
#define PLACEHOLDER @"Write something here..."
#define ROOTURL @"http://testphotos95.appspot.com/"
#import <QuartzCore/QuartzCore.h>


@interface ComposeCommentViewController ()

@end

@implementation ComposeCommentViewController
@synthesize typedText = _typedText;
@synthesize articleKey = _articleKey;

- (NSString *)articleKey
{
    if (!_articleKey) {
        _articleKey = [NSString string];
    }
    return _articleKey;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] != 0) {
        textView.backgroundColor = [UIColor whiteColor];
    } else {
        textView.backgroundColor = [UIColor clearColor];
    }
}



- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    NSValue *keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardSize = [keyboardFrameBegin CGRectValue];
    
    CGRect tempFrame = self.textView.frame;
    tempFrame.size.height -= keyboardSize.size.height;
    self.textView.frame = tempFrame;
}

- (void)cancelPressed
{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
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

- (void)sendPressed
{
    
    if (self.textView.text.length == 0) {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Comment"
                                                          message:@"Please add a comment before posting."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [message show];
        return;
    }
    [self.textView resignFirstResponder];
    //NSLog(@"%@", self.textView.text);
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@Comments/%@", ROOTURL, self.articleKey]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[self encodeDictionary:[NSDictionary dictionaryWithObject:self.textView.text forKey:@"comment"]]];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] && !error) {
                                   NSArray *ary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil];
                                   NSLog(@"%@", ary);
                               } else {
                                   UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Could not post"
                                                                                     message:@"Please check your 3G or Wifi connection."
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil];
                                   [message show];

                               }
                           }];
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Post Comment";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendPressed)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(sendPressed)];
    
    UITextView *placeTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    placeTextView.backgroundColor = [UIColor whiteColor];
    placeTextView.text = @"Write comment...";
    placeTextView.textColor = [UIColor lightGrayColor];
    placeTextView.font = [UIFont systemFontOfSize:14.0];
    placeTextView.userInteractionEnabled = NO;
    placeTextView.layer.cornerRadius = 5;
    [self.view addSubview:placeTextView];
    
    
    
    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    textView.layer.cornerRadius = 5;
    self.textView = textView;
    self.textView.font = [UIFont systemFontOfSize:14.0];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.scrollEnabled = YES;
    self.textView.userInteractionEnabled = YES;
    self.textView.delegate = self;
    [self.view addSubview:self.textView];
    [self.textView becomeFirstResponder];

    
}



@end
