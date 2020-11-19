//
//  ExceptionWrapper.m
//  Chat.WebSync4
//
//  Created by Frozen Mountain Software on 2016-10-25.
//  Copyright © 2016 Frozen Mountain Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExceptionWrapper.h"

@implementation ExceptionWrapper

+ (BOOL)catchException:(void(^)())tryBlock error:(__autoreleasing NSError **)error {
    @try {
        tryBlock();
        return YES;
    }
    @catch (NSException *exception) {
        *error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
    }
}

@end
