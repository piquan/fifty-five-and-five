//
//  AlarmSoundManager.h
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AlarmSound : NSObject <AVAudioPlayerDelegate>

@property NSString * _Nonnull identifier;
@property NSString * _Nonnull localizedName;
@property NSURL * _Nonnull urlToSoundFile;

- (NSString * _Nonnull)filename;

- (id _Nullable)initWithIdentifier:(NSString * _Nonnull)identifier
                              name:(NSString * _Nonnull)name
                          filename:(NSString * _Nonnull)filename;

- (void)play;
- (void)alarm;
- (void)stop;

@end

@interface AlarmSoundManager : NSObject

@property NSArray<AlarmSound*>* _Nonnull alarmSounds;
@property NSUInteger currentAlarmSoundIdx;

+ (AlarmSoundManager * _Nonnull)sharedInstance;
- (AlarmSound * _Nonnull)currentAlarm;
- (void)stopAll;

@end
