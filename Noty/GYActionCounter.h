//
//  GYActionCounter.h
//  Noty
//
//  Created by Guanqing Yan on 3/18/15.
//  Copyright (c) 2015 Guanqing Yan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GYActionCounter : NSObject
+(NSArray*)allActions;
+(void)initialize;
+(void)setCount:(NSUInteger)count Handler:(void (^)())handler ForTask:(NSString*)taskname;
+(NSUInteger)getCountForTask:(NSString*)taskname;
+(void)decreaseCountForTask:(NSString*)taskname;
@end
