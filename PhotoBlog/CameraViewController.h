//
//  CameraViewController.h
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-28.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@interface CameraViewController : UIViewController

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureVideoDataOutput *output;

@end
