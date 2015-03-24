//
//  ViewController.h
//  Noty
//
//  Created by Guanqing Yan on 3/17/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface ViewController : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *noteView;
@property (strong)Note* doc;
@end

