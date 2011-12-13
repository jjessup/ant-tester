//
//  Workout.h
//  ant-tester
//
//  Created by Jeremy Jessup on 12/13/11.
//  Copyright (c) 2011 The Active Network Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface Workout : NSObject
	<NSCoding>
{
	NSDateFormatter *dateFormatter;
	NSString		*dateString;
	
	WorkoutType		 workoutType;
	NSInteger		 duration;
	float			 distance;
}

@property (nonatomic, assign) WorkoutType workoutType;
@property (nonatomic, assign) NSInteger duration;
@property (nonatomic, assign) float distance;

- (id)initWithType:(WorkoutType)wt;

- (void)setDate:(NSDate*)date;
- (void)reset;
- (NSDate*)dateFromString;
- (NSString*)dateAsString;

@end
