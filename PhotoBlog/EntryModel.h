//
//  EntryModel.h
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-10-12.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EntryModel : NSObject

+ (EntryModel *)shareStore;
- (void)reloadEntriesFromWebWithCompletion:(void (^) (NSError *error))block;
- (UIImage *)imageForKey:(NSString *)photoKey;

@property (strong, nonatomic) NSMutableArray *arrayOfEntries;
@property (strong, nonatomic) NSMutableDictionary *dictionaryOfPhotos;
@property (strong, nonatomic) NSMutableDictionary *imageDownloaderForPhotoKey;

@end
