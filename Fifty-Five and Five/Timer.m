//
//  Timer.m
//  Fifty-Five and Five
//  Copyright © 2016 Joel Ray Holveck
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
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