//
//  ImageDownloader.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-16.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "ImageDownloader.h"
#import "EntryModel.h"
#import <dispatch/dispatch.h> 
#define ROOTURL @"http://testphotos95.appspot.com/"

@implementation ImageDownloader
@synthesize delegates = _delegates;

- (NSMutableArray *)delegates
{
    if (!_delegates) {
        _delegates = [[NSMutableArray alloc]init];
    }
    return _delegates;
}

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)downloadImageForKey:(NSString *)photoKey
{
    if (![[[EntryModel shareStore]imageDownloaderForPhotoKey]objectForKey:photoKey]) {
        [[[EntryModel shareStore]imageDownloaderForPhotoKey]setObject:self forKey:photoKey];
        NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"%@Photo/%@", ROOTURL, photoKey]];
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
        [urlRequest setHTTPMethod:@"GET"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] && !error) {
                                   UIImage *image = [[UIImage alloc]initWithData:data];
                                   UIGraphicsBeginImageContextWithOptions(CGSizeMake(260,260), NO, 0.0);
                                   [image drawInRect:CGRectMake(0, 0, 260, 260)];
                                   UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                                   UIGraphicsEndImageContext();
                                   [[[EntryModel shareStore] dictionaryOfPhotos] setObject:newImage forKey:photoKey];
                                   [[[EntryModel shareStore]imageDownloaderForPhotoKey]removeObjectForKey:photoKey];
                                   for (id delegate in self.delegates) {
                                       [delegate imageDownloader:self didFinishDownloadingImageForPhotoKey:photoKey];
                                   }
                               } else {
                                   /*UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Internet"
                                                                                     message:@"Please check your 3G or Wifi connection."
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil];
                                   [message show];*/

                               }
                           }];
        });
    } else {
        ImageDownloader *imageDownloader = [[[EntryModel shareStore]imageDownloaderForPhotoKey]objectForKey:photoKey];
        for (id delegate in self.delegates) {
            [imageDownloader.delegates addObject:delegate];
        }
    }
    
    
}

@end
