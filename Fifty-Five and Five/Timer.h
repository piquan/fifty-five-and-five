//
//  Timer.h
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/9/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Timer : NSObject <NSCoding>

@property NSString * _Nonnull name;
@property NSTimeInterval interval;
@property UIColor * _Nullable color;

- (id _Nonnull)initWithName:(NSString* _Nonnull)name
                   interval:(NSTimeInterval)interval;

- (NSString * _Nonnull)callToAction;

@end

