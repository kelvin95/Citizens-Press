//
//  ComposeCommentViewController.h
//  PhotoBlog
//
//  Created by Kelvin Wong on 12-11-28.
//  Copyright (c) 2012 Kelvin Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeCommentViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) NSString *typedText;
@property (strong, nonatomic) NSString *articleKey;


@end
