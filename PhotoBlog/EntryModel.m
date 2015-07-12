//
//  EntryModel.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-10-12.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "EntryModel.h"
#import "Entry.h"
#import <dispatch/dispatch.h>
#define ROOTURL @"http://testphotos95.appspot.com/"

@implementation EntryModel
@synthesize arrayOfEntries = _arrayOfEntries;
@synthesize dictionaryOfPhotos = _dictionaryOfPhotos;
@synthesize imageDownloaderForPhotoKey = _imageDownloaderForPhotoKey;

- (NSMutableDictionary *)imageDownloaderForPhotoKey
{
    if (!_imageDownloaderForPhotoKey) {
        _imageDownloaderForPhotoKey = [[NSMutableDictionary alloc]init];
    }
    return _imageDownloaderForPhotoKey;
}


- (NSMutableArray *)arrayOfEntries
{
    if (!_arrayOfEntries) {
        _arrayOfEntries = [[NSMutableArray alloc]init];
    }
    return _arrayOfEntries;
}

- (NSMutableDictionary *)dictionaryOfPhotos
{
    if (!_dictionaryOfPhotos) {
        _dictionaryOfPhotos = [[NSMutableDictionary alloc]init];
    }
    return _dictionaryOfPhotos;
}

+ (EntryModel *)shareStore
{
    static EntryModel *feedStore = nil;
    if (!feedStore) feedStore = [[EntryModel alloc]init];
    return feedStore;
}

- (UIImage *)imageForKey:(NSString *)photoKey
{
    return [self.dictionaryOfPhotos objectForKey:photoKey];
}

- (NSMutableArray *)makeArrayFromJSON:(NSArray *)array
{
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    for (id obj in array) {
        NSDateFormatter *format = [[NSDateFormatter alloc]init];
        [format setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            Entry *entry = [[Entry alloc]init];
            entry.articleKey = [obj objectForKey:@"articleKey"];
            entry.city = [obj objectForKey:@"city"];
            entry.country = [obj objectForKey:@"country"];
            entry.datetime = [format dateFromString:[obj objectForKey:@"datetime"]];
            entry.headline = [obj objectForKey:@"headline"];
            entry.photoKeys = [[NSMutableArray alloc]initWithArray:[obj objectForKey:@"photoKeys"] copyItems:YES];
            entry.text = [obj objectForKey:@"text"];
            [returnArray addObject:entry];
        }
    }
    return returnArray;
}



- (void)reloadEntriesFromWebWithCompletion:(void (^)(NSError *error))block
{
    //NSLog(@"Loading data");
    NSURL *url = [[NSURL alloc]initWithString:ROOTURL];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc]initWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] && !error) {
                                   NSArray *ary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:nil];
                                   self.arrayOfEntries = [self makeArrayFromJSON:ary];
                                   //[self downloadPhotosWithCompletion:block];
                                   block(nil);
                               } else {
                                   /*UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Internet"
                                                                                     message:@"Please check your 3G or Wifi connection."
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil];
                                   [message show];
                                   NSLog(@"Error From Entry");*/
                                   block(error);
                               }
    }];
}



@end