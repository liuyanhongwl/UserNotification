//
//  Macro.h
//  UserNotification
//
//  Created by Hong on 16/9/20.
//  Copyright © 2016年 Hong. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

#define MInterfaceSharedInstance(methodName) \
+ (instancetype)methodName;

#define MImplementeSharedInstance(methodName)  \
+ (instancetype)methodName{ \
    static dispatch_once_t onceToken; \
    static id instance; \
    dispatch_once(&onceToken, ^{ \
    instance = [[[self class] alloc] init]; \
    }); \
    return instance; \
} \



#endif /* Macro_h */
