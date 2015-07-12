//
//  CommentsViewController.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-14.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "CommentsViewController.h"
#import "ComposeCommentViewController.h"
#define ROOTURL @"http://testphotos95.appspot.com/"
#define COMMENTTAG 1


@interface CommentsViewController ()

@end

@implementation CommentsViewController
@synthesize tableView = _tableView;
@synthesize entry = _entry;
@synthesize arrayOfComments = _arrayOfComments;

- (NSMutableArray *)arrayOfComments
{
    if (!_arrayOfComments) {
        _arrayOfComments = [[NSMutableArray alloc]init];
        [self loadComments];
    }
    return _arrayOfComments;
}

- (void)loadComments
{
    //NSLog(@"%@", self.entry.articleKey);
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@Comments/%@", ROOTURL, self.entry.articleKey]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[[NSOperationQueue alloc]init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] && !error) {
                                   self.arrayOfComments = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil];
                                   //NSLog(@"%@", self.arrayOfComments);
                                   [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                               } else {
                                   /*
                                   UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Internet"
                                                                                     message:@"Please check your 3G or Wifi connection."
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil];
                                   [message show];*/

                               }
                           }];

}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        UIView *InfoView = [[UIView alloc]initWithFrame:CGRectZero];
        
        UILabel *headlineLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        headlineLabel.numberOfLines = 0;
        headlineLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
        headlineLabel.textAlignment = NSTextAlignmentLeft;
        headlineLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [InfoView addSubview:headlineLabel];
        
        UILabel *dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        dateLabel.font = [UIFont systemFontOfSize:12.0];
        dateLabel.textAlignment = NSTextAlignmentLeft;
        dateLabel.textColor = [UIColor grayColor];
        [InfoView addSubview:dateLabel];
        
        UILabel *locationLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        locationLabel.font = [UIFont systemFontOfSize:12.0];
        locationLabel.textAlignment = NSTextAlignmentLeft;
        locationLabel.textColor = [UIColor grayColor];
        [InfoView addSubview:locationLabel];
        
        
        headlineLabel.text = self.entry.headline;
        CGSize maxSize = CGSizeMake(280, 9999);
        CGSize stringSize = [headlineLabel.text sizeWithFont:headlineLabel.font constrainedToSize:maxSize lineBreakMode:headlineLabel.lineBreakMode];
        headlineLabel.frame = CGRectMake(20, 20, self.view.bounds.size.width-40, stringSize.height);
        
        locationLabel.text = [NSString stringWithFormat:@"%@, %@", self.entry.city, self.entry.country];
        stringSize = [locationLabel.text sizeWithFont:locationLabel.font constrainedToSize:maxSize lineBreakMode:locationLabel.lineBreakMode];
        locationLabel.frame = CGRectMake(20, headlineLabel.bounds.size.height+20,self.view.bounds.size.width-40 , stringSize.height);
        
        
        NSLocale *locale = [NSLocale currentLocale];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
        [formatter setDateFormat:dateFormat];
        [formatter setLocale:locale];
        dateLabel.text = [formatter stringFromDate:self.entry.datetime];
        stringSize = [dateLabel.text sizeWithFont:dateLabel.font constrainedToSize:maxSize lineBreakMode:dateLabel.lineBreakMode];
        dateLabel.frame = CGRectMake(20, locationLabel.bounds.size.height+headlineLabel.bounds.size.height+20, self.view.bounds.size.width-40, stringSize.height);
        
        InfoView.frame = CGRectMake(0, 0, self.view.bounds.size.width, headlineLabel.bounds.size.height + locationLabel.bounds.size.height + dateLabel.bounds.size.height+10);
        _tableView.tableHeaderView = InfoView;
    }
    return _tableView;
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}*/

#pragma mark - Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayOfComments count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%g", ((UILabel *)[[self tableView:self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:COMMENTTAG]).bounds.size.height);
    return ((UILabel *)[[self tableView:self.tableView cellForRowAtIndexPath:indexPath] viewWithTag:COMMENTTAG]).bounds.size.height + 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *commentCell = [self.tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    if (!commentCell) {
        commentCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell"];
        commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        commentCell.contentView.backgroundColor = [UIColor whiteColor];
        UILabel *comment = [[UILabel alloc]initWithFrame:CGRectZero];
        comment.tag = COMMENTTAG;
        comment.numberOfLines = 0;
        comment.font = [UIFont systemFontOfSize:12.0];
        comment.textAlignment = NSTextAlignmentLeft;
        comment.lineBreakMode = NSLineBreakByWordWrapping;
        [commentCell.contentView addSubview:comment];
        
        
    }
    
    UILabel *comment = ((UILabel *)[commentCell viewWithTag:COMMENTTAG]);
    //NSLog(@"%i%@", [indexPath row], [[self.arrayOfComments objectAtIndex:[indexPath row]] objectForKey:@"data"]);
    comment.text = [[self.arrayOfComments objectAtIndex:[indexPath row]] objectForKey:@"data"];
    //comment.text = @"This is a really really long comment for testing purposes!";
    CGSize maxSize = CGSizeMake(280, 9999);
    CGSize stringSize = [comment.text sizeWithFont:comment.font constrainedToSize:maxSize lineBreakMode:comment.lineBreakMode];
    comment.frame = CGRectMake(20, 20, self.tableView.bounds.size.width-40, stringSize.height);
    return commentCell;
}

- (void)commentComposePressed
{
    ComposeCommentViewController *ccvc = [[ComposeCommentViewController alloc]init];
    ccvc.articleKey = [self.entry articleKey];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:ccvc];
    navController.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:navController animated:YES completion:nil];
}





- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Comments";
    }
    return self;
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.frame = self.view.frame;
    [self.view addSubview:self.tableView];
    [self loadComments];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(commentComposePressed)];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
