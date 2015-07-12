//
//  Entry.h
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-10-11.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Entry : NSObject

@property (strong, nonatomic) NSString *articleKey;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSDate *datetime;
@property (strong, nonatomic) NSString *headline;
@property (strong, nonatomic) NSMutableArray *photoKeys;
@property (strong, nonatomic) NSString *text;

@end
