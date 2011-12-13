//
//  PlayerData.h
//  ant-tester
//
//  Created by Jeremy Jessup on 12/13/11.
//  Copyright (c) 2011 The Active Network Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class Workout;

@interface PlayerData : NSObject
	<NSCoding>
{
	AvatarType		avatarType;				// type of avatar
	NSInteger		starCount;				// number of stars earned
	NSString		*name;					// player name
	
	NSMutableArray  *workoutHistory;		// history of Workout objects
}

@property (nonatomic, assign) AvatarType avatarType;
@property (nonatomic, assign) NSInteger starCount;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *workoutHistory;

// Returns a workout object
- (Workout*)getWorkoutHistory:(NSInteger)index;

// Store a workout to the player's record
- (void)addWorkout:(Workout*)w;

@end
