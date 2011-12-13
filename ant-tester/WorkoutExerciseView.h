//
//  WorkoutExerciseView.h
//  c25k
//
//  Created by Jeremy Jessup on 5/10/11.
//  Copyright 2011 The Active Network. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>

@class MusicControlView;
@class UserWorkoutLog;
@class Workout;

typedef enum
{
	WEV_GetReady,
	WEV_InProgress,
	WEV_Paused,
	WEV_Complete,
} WEV_State;

////////////////////////////////////////////////////////////////////////////////
//
// WorkoutExerciseView
//
////////////////////////////////////////////////////////////////////////////////

@interface WorkoutExerciseView : UIViewController 
	<CLLocationManagerDelegate, AVAudioPlayerDelegate>
{
	id delegate;								// delegate for protocol messages
	NSArray *exerciseList;						// list of exercises
	NSInteger workoutIndex;						// index from master workout

	Workout *workout;
	
	UserWorkoutLog *userLog;					// pointer to current workout
	
	WEV_State state;
	
	BOOL audioBeginWorkout;						// play "lets go" only once
	BOOL audioHalfwayOnce;
	BOOL audioEncourageOnce;
	
	CLLocationManager *locationManager;
	IBOutlet UIButton *gpsButton;
	BOOL gpsEnabled;
	
	NSInteger currentStep;						// which stage of the exercise we're doing
	NSInteger currentSeconds;					// time elapsed on current step (count down)
	NSInteger totalSecondsLeft;					// overall total for the workout (count down)
	NSInteger totalTimeExercising;				// time could exceed workout duration if steps are repeated (count up)
	NSTimer *stepTimer;							// timer
	
	NSTimer *gpsTimer;							// timer
	
	UIImageView *startCompleteBkgd;				// background for beginning/end of workout
	UIImageView *stepBkgd;						// background for the exercise steps
	
//	IBOutlet UIButton *tempXUpBtn;				// temp buttons to adjust the track graphic positions
//	IBOutlet UIButton *tempXDownBtn;
//	IBOutlet UIButton *tempYUpBtn;
//	IBOutlet UIButton *tempYDownBtn;
//	IBOutlet UIButton *tempIdxUpBtn;
//	IBOutlet UIButton *tempIdxDownBtn;
//	NSInteger tempIdx;							// texture index
//	NSInteger skipStep;							// button stride
	
	NSMutableArray *trackCircleImageViewList;	// array of track textures
	
//	IBOutlet MusicControlView *musicControlView;// music player controls
	
	IBOutlet UILabel *stepCommand;				// run, walk, jog, etc.
	
	IBOutlet UILabel *startCompleteCommand;
	IBOutlet UILabel *startCompleteText;		// "start" and "complete" text
	IBOutlet UIButton *startCompleteButton;		// button for the start/complete state
	
	IBOutlet UIButton *doneButton;				// text/button for the 'done' button
	IBOutlet UILabel *doneText;
	IBOutlet UILabel *timeLeftText;				// "time left" text
	
	IBOutlet UIButton *previousButton;			// previous exercise step
	IBOutlet UIButton *nextButton;				// next exercise step
	IBOutlet UIButton *actionButton;			// pause/continue/start
	IBOutlet UILabel *actionButtonText;
	
	IBOutlet UILabel *stepNext;					// "up next:"
	IBOutlet UILabel *stepNextExercise;			// Run (3:00)
	
	UIImageView *blueTimeDot;					// ':'
	UIImageView *greenTimeDot;					// ':'
	
	UIImageView *greenMinTens;					// images for the big green timer
	UIImageView *greenMinOnes;
	UIImageView *greenSecTens;
	UIImageView *greenSecOnes;
	
	UIImageView *blueMinTens;					// images for the small blue timer
	UIImageView *blueMinOnes;
	UIImageView *blueSecTens;
	UIImageView *blueSecOnes;
	
	NSArray *greenNumbers;						// image array for green textures
	NSArray *blueNumbers;						// image array for the blue textures
	NSArray *redNumbers;						// image array for red textures
    
    NSDate *lastStepStartedDate;
    NSDate *workoutStartDate;
    
//    BOOL backgroundSupported;
//    IBOutlet UIButton *mapButton;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) NSInteger workoutIndex;
@property (nonatomic, assign) NSArray *exerciseList;
@property (nonatomic, retain) Workout *workout;

//@property (nonatomic, retain) NSDate *workoutStartDate;
//@property (nonatomic, retain) UIButton *mapButton;

// Purpose: previous workout step button pressed
- (IBAction)previousButtonPressed:(id)sender;

// Purpose: next workout step button pressed
- (IBAction)nextButtonPressed:(id)sender;

//Purpose: Reset local notifications
//- (void) resetLocalNotifications;

// Purpose: play/pause/resume (action) button pressed
- (IBAction)actionButtonPressed:(id)sender;

// Purpose: done button pressed
- (IBAction)doneButtonPressed:(id)sender;

// Purpose: toggle whether the gps is enabled/disabled
- (void)startGPS;
- (void)stopGPS;

// Purpose: temporary callback methods for the adjustment widgets
//- (IBAction)tempXUpBtnPress:(id)sender;
//- (IBAction)tempXDownBtnPress:(id)sender;
//- (IBAction)tempYUpBtnPress:(id)sender;
//- (IBAction)tempYDownBtnPress:(id)sender;
//- (IBAction)tempIdxUpBtnPress:(id)sender;
//- (IBAction)tempIdxDownBtnPress:(id)sender;
//- (IBAction)tempSkipStepUpPress:(id)sender;
//- (IBAction)tempSkipStepDownPress:(id)sender;
//
////Purpose: display map during workout
//- (IBAction)mapButtonPressed:(id)sender;

@end

////////////////////////////////////////////////////////////////////////////////
//
// WorkoutExerciseView (Protocol)
//
////////////////////////////////////////////////////////////////////////////////

@protocol WorkoutExerciseView <NSObject>
@optional
// Purpose: sends a message to delegate when user has completed the workout flow
- (void)workoutComplete:(NSInteger)index;
@end

