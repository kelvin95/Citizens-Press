//
//  CameraViewController.m
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-28.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPrese;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

@end
