//
//  Entry.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-10-11.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "Entry.h"

@implementation Entry

@synthesize articleKey = _articleKey;
@synthesize city = _city;
@synthesize country = _country;
@synthesize datetime = _datetime;
@synthesize headline = _headline;
@synthesize photoKeys = _photoKeys;
@synthesize text = _text;

- (id)init
{
    self = [super init];
    if (self){
        _articleKey = [[NSString alloc]init];
        _city = [[NSString alloc]init];
        _country = [[NSString alloc]init];
        _datetime = [[NSDate alloc]init];
        _headline = [[NSString alloc]init];
        _photoKeys = [[NSMutableArray alloc]init];
        _text = [[NSString alloc]init];
    }
    return self;
}

@end
