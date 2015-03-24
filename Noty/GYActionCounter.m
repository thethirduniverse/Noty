//
//  GYActionCounter.m
//  Noty
//
//  Created by Guanqing Yan on 3/18/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

#import "GYActionCounter.h"
#define kCountKey @"kCountKey"
#define kHandlerKey @"kHandlerKey"
typedef void (^handler_t)();
@interface GYActionCounter();
@end
@implementation GYActionCounter
static NSMutableDictionary* _tasks;
+(NSArray*)allActions{
    assert(_tasks);
    return [_tasks allKeys];
}
+(void)initialize{
    _tasks = [[NSMutableDictionary alloc] init];
}
+(void)setCount:(NSUInteger)count Handler:(void (^)())handler ForTask:(NSString*)taskname{
    assert(_tasks);
    assert(taskname);
    assert(count>=0);
    [_tasks setValue:@{kCountKey:@(count),kHandlerKey:handler} forKey:taskname];
    if (count==0) {
        handler();
    }
}
+(NSUInteger)getCountForTask:(NSString*)taskname{
    assert(_tasks);
    assert(taskname);
    return (NSUInteger)[[[_tasks valueForKey:taskname] valueForKey:kCountKey] integerValue];
}
+(void)decreaseCountForTask:(NSString*)taskname{
    assert(taskname);
    assert(_tasks);
    @autoreleasepool {
        NSDictionary* d = [_tasks valueForKey:taskname];
        NSUInteger nc = ((NSUInteger)[[d valueForKey:kCountKey] integerValue])-1;
        if (nc==0) {
            ((handler_t)[d valueForKey:kHandlerKey])();
        }
        [_tasks setValue:@{kCountKey:@(nc),kHandlerKey:[d valueForKey:kHandlerKey]} forKey:taskname];
    }
}
@end
