//
//  ImageDownloader.h
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-16.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ImageDownloader;

@protocol ImageDownloaderProtocol <NSObject>

- (void)imageDownloader:(ImageDownloader *)imageDownloader didFinishDownloadingImageForPhotoKey:(NSString *)photoKey;

@end

@interface ImageDownloader : NSObject
- (id)init;
- (void)downloadImageForKey: (NSString *)photoKey;

@property (strong, nonatomic) NSMutableArray *delegates;
@property (strong, nonatomic) NSIndexPath *indexPath;



@end
