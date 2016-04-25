//
//  AlarmSoundManager.h
//  Fifty-Five and Five
//
//  Created by Joel Ray Holveck on 4/12/16.
//  Copyright © 2016 Joel Ray Holveck. All rights reserved.
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
