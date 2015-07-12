//
//  PhotoFeedNavigationViewController.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 1/16/2014.
//  Copyright (c) 2014 Kelvin Wong. All rights reserved.
//

#import "PhotoFeedNavigationViewController.h"
#import "AMNavigationBar.h"

@implementation PhotoFeedNavigationViewController

// the easy way to use it is to subclass UINavigationController and override:
- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithNavigationBarClass:[AMNavigationBar class] toolbarClass:[UIToolbar class]];
    if (self) {
        self.viewControllers = @[ rootViewController ];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
