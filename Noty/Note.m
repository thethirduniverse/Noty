//
//  Note.m
//  Noty
//
//  Created by Guanqing Yan on 3/17/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

#import "Note.h"

@implementation Note
-(BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError{
    if ([contents length]>0) {
        self.noteContent = [[NSString alloc] initWithBytes:[contents bytes] length:[contents length] encoding:NSUTF8StringEncoding];
    }
    else{
        self.noteContent = @"Empty";
    }
    return true;
}

-(id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError{
    if ([self.noteContent length]==0) {
        self.noteContent = @"Empty";
    }
    return [NSData dataWithBytes:[self.noteContent UTF8String] length:[self.noteContent length]];
}
//-(void)accommodatePresentedItemDeletionWithCompletionHandler:(void (^)(NSError *))completionHandler{
//    dispatch_queue_t q_default;
//    q_default = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(q_default, ^(void) {
//        [self closeWithCompletionHandler:^(BOOL success) {
//            NSLog(@"%d",success);
//            completionHandler(nil);
//        }];
//    });
//}
@end
