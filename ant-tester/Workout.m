//
//  Workout.m
//  ant-tester
//
//  Created by Jeremy Jessup on 12/13/11.
//  Copyright (c) 2011 The Active Network Inc. All rights reserved.
//

#import "Workout.h"

@interface Workout ()
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSString *dateString;
@end

@implementation Workout
@synthesize workoutType;
@synthesize duration;
@synthesize distance;
@synthesize dateFormatter;
@synthesize dateString;

- (id)initWithType:(WorkoutType)wt
{
	self = [super init];
	
	if (self)
	{
		workoutType		= wt;
		duration	= 0;
		distance		= 0.0f;
		
		dateFormatter	= [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		
		[self setDate:[NSDate date]];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	
	self.workoutType	= [coder decodeIntegerForKey:@"workoutType"];
	self.duration = [coder decodeIntegerForKey:@"duration"];
	self.distance		= [coder decodeFloatForKey:@"distance"];
	
	self.dateFormatter	= [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	self.dateString		= [NSString stringWithFormat:@"%@", [coder decodeObjectForKey:@"dateString"]];
	
	return self;
}

- (void)dealloc
{
	[dateFormatter release];
	[dateString release];
	
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInteger:workoutType forKey:@"workoutType"];
	[coder encodeInteger:duration forKey:@"duration"];
	[coder encodeFloat:distance forKey:@"distance"];
	[coder encodeObject:dateString forKey:@"dateString"];
}

- (void)setDate:(NSDate *)date
{
	self.dateString = [NSString stringWithString:[dateFormatter stringFromDate:date]];
}

- (void)reset
{
	[self setDate:[NSDate date]];
}

- (NSDate *)dateFromString
{
	return [dateFormatter dateFromString:self.dateString];
}

- (NSString*)dateAsString
{
	return self.dateString;
}

@end
