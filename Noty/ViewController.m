//
//  ViewController.m
//  Noty
//
//  Created by Guanqing Yan on 3/17/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.noteView setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReloaded:) name:UIDocumentStateChangedNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDocumentStateChangedNotification object:nil];
}
-(void)dataReloaded:(NSNotification*)notification{
    if ([notification object]==self.doc) {
        self.doc=notification.object;
        self.noteView.text = self.doc.noteContent;
    }
}
-(void)textViewDidChange:(UITextView *)textView{
    self.doc.noteContent = textView.text;
    [self.doc updateChangeCount:UIDocumentChangeDone];
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    [self.doc saveToURL:self.doc.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if (!success) {
            NSLog(@"failed");
        }
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.noteView.text = self.doc.noteContent;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
