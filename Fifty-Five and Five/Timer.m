//
//  Timer.m
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/9/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
//

#import "Timer.h"

@implementation Timer

static NSString * kName = @"name";
static NSString * kInterval = @"interval";

- (id)initWithName:(NSString* _Nonnull)name
          interval:(NSTimeInterval)interval
{
    self = [super init];
    if (self) {
        _name = name;
        _interval = interval;
        // FIXME Prepare and cache things like callToAction
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    return [self initWithName:[decoder decodeObjectForKey:kName]
                     interval:[decoder decodeDoubleForKey:kInterval]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_name forKey:kName];
    [coder encodeDouble:_interval forKey:kInterval];
}

- (NSString*)callToAction
{
    return [NSString stringWithFormat:NSLocalizedString(@"Time to %@", nil), self.name];
}

@end