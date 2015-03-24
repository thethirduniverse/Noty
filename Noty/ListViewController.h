//
//  ListViewController.h
//  Noty
//
//  Created by Guanqing Yan on 3/17/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "ViewController.h"

@interface ListViewController : UITableViewController
@property (strong) NSMutableArray* notes;
@property (strong) NSMetadataQuery* query;
-(void)loadNotes;
@end
