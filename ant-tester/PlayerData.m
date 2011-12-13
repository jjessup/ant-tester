//
//  PlayerData.m
//  ant-tester
//
//  Created by Jeremy Jessup on 12/13/11.
//  Copyright (c) 2011 The Active Network Inc. All rights reserved.
//

#import "PlayerData.h"

@interface PlayerData ()
- (void)reset;
@end

@implementation PlayerData
@synthesize avatarType;
@synthesize starCount;
@synthesize name;
@synthesize workoutHistory;

- (id)init
{
	self = [super init];
	
	if (self)
	{
		workoutHistory = [[NSMutableArray alloc] init];

		[self reset];
	}
	
	return self;
}

- (void)dealloc
{
	[name release];
	[workoutHistory release];
	
	[super dealloc];
}

- (id)initWithCoder:(NSCoder*)coder
{
	self = [super init];
	
	self.avatarType		= [coder decodeIntegerForKey:@"avatarType"];
	self.starCount		= [coder decodeIntegerForKey:@"starCount"];
	self.name			= [coder decodeObjectForKey:@"name"];
	self.workoutHistory = [coder decodeObjectForKey:@"workoutHistory"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeInteger:avatarType forKey:@"avatarType"];
	[coder encodeInteger:starCount forKey:@"starCount"];
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:workoutHistory forKey:@"workoutHistory"];
}

- (void)reset
{
	avatarType = kAvatar_None;
	starCount  = 0;
	name       = @"";
	
	[workoutHistory removeAllObjects];
}

- (Workout*)getWorkoutHistory:(NSInteger)index
{
	return [workoutHistory objectAtIndex:index];
}

- (void)addWorkout:(Workout*)w
{
	[workoutHistory addObject:w];
}

@end
