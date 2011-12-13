//
//  WorkoutExerciseView.m
//  c25k
//
//  Created by Jeremy Jessup on 5/10/11.
//  Copyright 2011 The Active Network. All rights reserved.
//

#import "WorkoutExerciseView.h"
#import "Workout.h"
//#import "WorkoutData.h"
//#import "UserData.h"
//#import "JournalDetailView.h"
//#import "MusicControlView.h"
//#import "TrainerData.h"
//#import "c25kAppDelegate.h"
//#import "AppData.h"
//#import "AchievementData.h"
//#import "DataConstants.h"
//#import "ActiveTrainerView.h"
//#import "UIImage+Loading.h"
//#import "NSArray+Safe.h"
//#import "SettingsView.h"
//#import "JournalDetailMapView.h"

// static to hold the overall expected total duration of this workout
static NSInteger expectedExerciseDuration = 0;
static NSInteger NUM_TRACK_SEGMENTS		  = 40;

@interface WorkoutExerciseView ()
@property (nonatomic, assign) WEV_State state;
@property (nonatomic, assign) UserWorkoutLog *userLog;
@property (nonatomic, assign) BOOL audioBeginWorkout;
@property (nonatomic, assign) BOOL audioHalfwayOnce;
@property (nonatomic, assign) BOOL audioEncourageOnce;
@property (nonatomic, retain) UIButton *previousButton;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *actionButton;
@property (nonatomic, retain) UILabel *actionButtonText;
@property (nonatomic, retain) UILabel *stepCommand;
@property (nonatomic, retain) UILabel *stepNext;
@property (nonatomic, retain) UILabel *timeLeftText;
@property (nonatomic, retain) UILabel *stepNextExercise;
@property (nonatomic, assign) UIImageView *startCompleteBkgd;
@property (nonatomic, assign) UIImageView *stepBkgd;
@property (nonatomic, retain) UILabel *startCompleteText;
@property (nonatomic, retain) UILabel *startCompleteCommand;
@property (nonatomic, retain) UIButton *startCompleteButton;
@property (nonatomic, retain) UIButton *doneButton;
@property (nonatomic, retain) UILabel *doneText;
@property (nonatomic, assign) NSInteger currentStep;
@property (nonatomic, assign) NSInteger currentSeconds;
@property (nonatomic, assign) NSInteger totalSecondsLeft;
@property (nonatomic, assign) NSInteger totalTimeExercising;
@property (nonatomic, retain) NSTimer *stepTimer;
@property (nonatomic, retain) NSTimer *gpsTimer;
@property (nonatomic, retain) MusicControlView *musicControlView;
@property (nonatomic, assign) UIImageView *blueTimeDot;
@property (nonatomic, assign) UIImageView *greenTimeDot;
@property (nonatomic, assign) UIImageView *greenMinTens;
@property (nonatomic, assign) UIImageView *greenMinOnes;
@property (nonatomic, assign) UIImageView *greenSecTens;
@property (nonatomic, assign) UIImageView *greenSecOnes;
@property (nonatomic, assign) UIImageView *blueMinTens;
@property (nonatomic, assign) UIImageView *blueMinOnes;
@property (nonatomic, assign) UIImageView *blueSecTens;
@property (nonatomic, assign) UIImageView *blueSecOnes;
@property (nonatomic, assign) NSArray *greenNumbers;
@property (nonatomic, assign) NSArray *redNumbers;
@property (nonatomic, assign) NSArray *blueNumbers;
@property (nonatomic, retain) NSMutableArray *trackCircleImageViewList;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) UIButton *gpsButton;
@property (nonatomic, assign) BOOL gpsEnabled;

//@property (nonatomic, retain) UIButton *tempXUpBtn;
//@property (nonatomic, retain) UIButton *tempXDownBtn;
//@property (nonatomic, retain) UIButton *tempYUpBtn;
//@property (nonatomic, retain) UIButton *tempYDownBtn;
//@property (nonatomic, retain) UIButton *tempIdxUpBtn;
//@property (nonatomic, retain) UIButton *tempIdxDownBtn;
//@property (nonatomic, assign) NSInteger tempIdx;
//@property (nonatomic, assign) NSInteger skipStep;

- (void)setWorkoutStep:(NSInteger)step;
- (void)updateTimerDisplay;
- (void)setButtonsForState;
- (void)handleWorkoutComplete;

- (void)setupTimer;
- (void)invalidateTimer;
- (void)shutdownLocationManager;
- (void)shutdownMusicPlayback;
- (void)achievementViewDismissed;
//- (void)adjustTimeForForeground:(NSNotification *)notif;

// forward declare
//- (void)requestFinished:(ActiveTrainerRequest)request withResult:(ActiveTrainerResult)result;

@end

@implementation WorkoutExerciseView
@synthesize state;
@synthesize userLog;
@synthesize workout;
@synthesize audioBeginWorkout;
@synthesize audioHalfwayOnce;
@synthesize audioEncourageOnce;
@synthesize delegate;
@synthesize exerciseList;
@synthesize workoutIndex;
@synthesize previousButton;
@synthesize nextButton;
@synthesize actionButton;
@synthesize actionButtonText;
@synthesize stepCommand;
@synthesize stepNext;
@synthesize timeLeftText;
@synthesize stepNextExercise;
@synthesize currentStep;
@synthesize currentSeconds;
@synthesize totalSecondsLeft;
@synthesize totalTimeExercising;
@synthesize stepTimer;
@synthesize gpsTimer;
@synthesize musicControlView;
@synthesize startCompleteBkgd;
@synthesize stepBkgd;
@synthesize startCompleteText;
@synthesize startCompleteCommand;
@synthesize startCompleteButton;
@synthesize doneButton;
@synthesize doneText;
@synthesize blueTimeDot;
@synthesize greenTimeDot;
@synthesize greenMinTens;
@synthesize greenMinOnes;
@synthesize greenSecTens;
@synthesize greenSecOnes;
@synthesize blueMinTens;
@synthesize blueMinOnes;
@synthesize blueSecTens;
@synthesize blueSecOnes;
@synthesize blueNumbers;
@synthesize greenNumbers;
@synthesize redNumbers;
@synthesize trackCircleImageViewList;
@synthesize locationManager;
@synthesize gpsButton;
@synthesize gpsEnabled;

//@synthesize tempXUpBtn;
//@synthesize tempXDownBtn;
//@synthesize tempYUpBtn;
//@synthesize tempYDownBtn;
//@synthesize tempIdxUpBtn;
//@synthesize tempIdxDownBtn;
//@synthesize tempIdx;
//@synthesize skipStep;

//@synthesize workoutStartDate;

//@synthesize mapButton;

- (CGRect)getProgressImagePosition:(NSInteger)index withWidth:(float)width withHeight:(float)height
{
	CGFloat x, y;
	
	switch (index)
	{
		case 0:	 x = 220; y = 228; break;
		case 1:	 x = 227; y = 228; break;
		case 2:  x = 238; y = 228; break;
		case 3:  x = 250; y = 228; break;
		case 4:  x = 263; y = 228; break;
		case 5:  x = 276; y = 228; break;
		case 6:  x = 273; y = 210; break;
		case 7:  x = 273; y = 194; break;
		case 8:  x = 273; y = 176; break;
		case 9:  x = 273; y = 159; break;
		case 10: x = 273; y = 142; break;
		case 11: x = 273; y = 120; break;
		case 12: x = 257; y = 120; break;
		case 13: x = 242; y = 120; break;
		case 14: x = 229; y = 120; break;
		case 15: x = 216; y = 120; break;
		case 16: x = 202; y = 120; break;
		case 17: x = 188; y = 120; break;
		case 18: x = 174; y = 120; break;
		case 19: x = 160; y = 120; break;
			
		case 20: x = 146; y = 120; break;
		case 21: x = 132; y = 120; break;
		case 22: x = 118; y = 120; break;
		case 23: x = 104; y = 120; break;
		case 24: x =  91; y = 120; break;
		case 25: x =  77; y = 120; break;
		case 26: x =  63; y = 120; break;
		case 27: x =  47; y = 120; break;
		case 28: x =   2; y = 120; break;
		case 29: x =   2; y = 142; break;
		case 30: x =   2; y = 159; break;
		case 31: x =   2; y = 176; break;
		case 32: x =   2; y = 194; break;
		case 33: x =   2; y = 210; break;
		case 34: x =   2; y = 228; break;
		case 35: x =  44; y = 228; break;
		case 36: x =  57; y = 228; break;
		case 37: x =  70; y = 228; break;
		case 38: x =  82; y = 228; break;
		case 39: x =  93; y = 228; break;
		default: x =   0; y =   0; break;
	}
	
	return CGRectMake(x, y, width, height);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
		// helps hide cross-fade see-through
		self.view.backgroundColor = [UIColor blackColor];
		
		self.greenNumbers = [[NSArray alloc] initWithObjects:
							 [UIImage imageNamed:@"assets/img/timer/green/0.png"],
							 [UIImage imageNamed:@"assets/img/timer/green/1.png"],
							 [UIImage imageNamed:@"assets/img/timer/green/2.png"],
							 [UIImage imageNamed:@"assets/img/timer/green/3.png"],
							 [UIImage imageNamed:@"assets/img/timer/green/4.png"],
							 [UIImage imageNamed:@"assets/img/timer/green/5.png"],
							 [UIImage imageNamed:@"assets/img/timer/green/6.png"],
							 [UIImage imageNamed:@"assets/img/timer/green/7.png"],
							 [UIImage imageNamed:@"assets/img/timer/green/8.png"],
							 [UIImage imageNamed:@"assets/img/timer/green/9.png"],
							 nil];
		
		self.redNumbers = [[NSArray alloc] initWithObjects:
						   [UIImage imageNamed:@"assets/img/timer/red/0.png"],
						   [UIImage imageNamed:@"assets/img/timer/red/1.png"],
						   [UIImage imageNamed:@"assets/img/timer/red/2.png"],
						   [UIImage imageNamed:@"assets/img/timer/red/3.png"],
						   [UIImage imageNamed:@"assets/img/timer/red/4.png"],
						   [UIImage imageNamed:@"assets/img/timer/red/5.png"],
						   [UIImage imageNamed:@"assets/img/timer/red/6.png"],
						   [UIImage imageNamed:@"assets/img/timer/red/7.png"],
						   [UIImage imageNamed:@"assets/img/timer/red/8.png"],
						   [UIImage imageNamed:@"assets/img/timer/red/9.png"],
						   nil];
		
		self.blueNumbers = [[NSArray alloc] initWithObjects:
							[UIImage imageNamed:@"assets/img/timer/blue/0.png"],
							[UIImage imageNamed:@"assets/img/timer/blue/1.png"],
							[UIImage imageNamed:@"assets/img/timer/blue/2.png"],
							[UIImage imageNamed:@"assets/img/timer/blue/3.png"],
							[UIImage imageNamed:@"assets/img/timer/blue/4.png"],
							[UIImage imageNamed:@"assets/img/timer/blue/5.png"],
							[UIImage imageNamed:@"assets/img/timer/blue/6.png"],
							[UIImage imageNamed:@"assets/img/timer/blue/7.png"],
							[UIImage imageNamed:@"assets/img/timer/blue/8.png"],
							[UIImage imageNamed:@"assets/img/timer/blue/9.png"],
							nil];
		
		trackCircleImageViewList = [[NSMutableArray alloc] initWithCapacity:NUM_TRACK_SEGMENTS];
		for (int i = 0; i < NUM_TRACK_SEGMENTS; ++i)
		{
			NSString *imgName = [NSString stringWithFormat:@"assets/img/timer/progress/Slice_%02d@2x", i];
			UIImage *img = [UIImage imageNamed:imgName];
			UIImageView *iv = [[UIImageView alloc] initWithFrame:[self getProgressImagePosition:i withWidth:img.size.width/2 withHeight:img.size.height/2]];
			iv.image = img;
			iv.alpha = 0.0f;
			[trackCircleImageViewList addObject:iv];

			[self.view addSubview:iv];
			[iv release];
		}
		
//		tempIdx = 0;
//		skipStep = 1;
		
        // Custom initialization
		self.startCompleteBkgd = [[UIImageView alloc] initWithFrame:self.view.frame];
		self.startCompleteBkgd.image = [UIImage imageNamed:@"assets/img/timer/background_complete"];
		self.startCompleteBkgd.alpha = 1.0f;
		[self.view addSubview:self.startCompleteBkgd];
		[self.view sendSubviewToBack:self.startCompleteBkgd];
		
		self.stepBkgd = [[UIImageView alloc] initWithFrame:self.view.frame];
		self.stepBkgd.image = [UIImage imageNamed:@"assets/img/timer/background"];
		self.stepBkgd.alpha = 0.0f;
		[self.view addSubview:self.stepBkgd];
		[self.view sendSubviewToBack:self.stepBkgd];
		
		self.greenMinTens = [[UIImageView alloc] initWithFrame:CGRectMake(45+52*0,		150, 47, 67)];
		self.greenMinOnes = [[UIImageView alloc] initWithFrame:CGRectMake(45+52*1,		150, 47, 67)];
		self.greenTimeDot = [[UIImageView alloc] initWithFrame:CGRectMake(45+52*2+10,	150, 10, 67)];
		self.greenSecTens = [[UIImageView alloc] initWithFrame:CGRectMake(45+52*3-20,	150, 47, 67)];
		self.greenSecOnes = [[UIImageView alloc] initWithFrame:CGRectMake(45+52*4-20,	150, 47, 67)];
		
		self.greenTimeDot.image = [UIImage imageNamed:@"assets/img/timer/green/dots"];
		
		[self.view addSubview:greenMinTens];
		[self.view addSubview:greenMinOnes];
		[self.view addSubview:greenTimeDot];
		[self.view addSubview:greenSecTens];
		[self.view addSubview:greenSecOnes];
		
		self.blueMinTens = [[UIImageView alloc] initWithFrame:CGRectMake(163+10*0,		237, 10, 12)];
		self.blueMinOnes = [[UIImageView alloc] initWithFrame:CGRectMake(164+10*1,		237, 10, 12)];
		self.blueTimeDot = [[UIImageView alloc] initWithFrame:CGRectMake(167+10*2+0,	237,  4, 12)];
		self.blueSecTens = [[UIImageView alloc] initWithFrame:CGRectMake(169+10*2+4,	237, 10, 12)];
		self.blueSecOnes = [[UIImageView alloc] initWithFrame:CGRectMake(170+10*3+4,	237, 10, 12)];
		
		self.blueTimeDot.image = [UIImage imageNamed:@"assets/img/timer/blue/dots"];
		
		[self.view addSubview:blueMinTens];
		[self.view addSubview:blueMinOnes];
		[self.view addSubview:blueTimeDot];
		[self.view addSubview:blueSecTens];
		[self.view addSubview:blueSecOnes];
		 
		[self.startCompleteButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_continue_off"] forState:UIControlStateNormal];
		[self.startCompleteButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_continue_press"] forState:UIControlStateHighlighted];
		
		[self.doneButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_done"] forState:UIControlStateNormal];
		[self.doneButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_done"] forState:UIControlStateHighlighted];
		
		[self.previousButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_arrow_left_off"] forState:UIControlStateNormal];
		[self.previousButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_arrow_left_press"] forState:UIControlStateHighlighted];
		
		[self.nextButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_arrow_right_off"] forState:UIControlStateNormal];
		[self.nextButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_arrow_right_press"] forState:UIControlStateHighlighted];
		
		[self.actionButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_pause_off"] forState:UIControlStateNormal];
		[self.actionButton setImage:[UIImage imageNamed:@"assets/img/timer/btn_pause_press"] forState:UIControlStateHighlighted];
		
		// initial button/text settings
		stepCommand.alpha = 0;
		actionButton.alpha = 0;
		actionButtonText.alpha = 0;
		stepNextExercise.alpha = 0;
		stepNext.alpha = 0;
		nextButton.alpha = 0;
		timeLeftText.alpha = 0;
		
		greenTimeDot.alpha = 0;
		greenMinTens.alpha = 0;
		greenMinOnes.alpha = 0;
		greenSecTens.alpha = 0;
		greenSecOnes.alpha = 0;
		blueTimeDot.alpha = 0;
		blueMinTens.alpha = 0;
		blueMinOnes.alpha = 0;
		blueSecTens.alpha = 0;
		blueSecOnes.alpha = 0;
		
		startCompleteButton.alpha = 1;
		startCompleteText.alpha = 1;
		startCompleteCommand.alpha = 1;
		doneButton.alpha = 1;
		
    }
    return self;
}

- (void)dealloc
{
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];

	delegate = nil;
	exerciseList = nil;
	
	[workout release];
	[previousButton release];
	[nextButton release];
	[actionButton release];
	[actionButtonText release];
	[stepCommand release];
	[stepNext release];
	[stepNextExercise release];
	[timeLeftText release];
	
	[stepBkgd release];
	[startCompleteBkgd release];
	[startCompleteText release];
	[startCompleteCommand release];
	[startCompleteButton release];
	[doneButton release];
	[doneText release];
	[trackCircleImageViewList release];
	
	locationManager.delegate = nil;
	[locationManager release];
	[gpsButton release];
	
//	app.audCtrl.delegate = nil;
//	[musicControlView release];
	
//	[tempXUpBtn release];
//	[tempXDownBtn release];
//	[tempYUpBtn release];
//	[tempYDownBtn release];
//	[tempIdxUpBtn release];
//	[tempIdxDownBtn release];
	
	[blueTimeDot release];
	[blueMinTens release];
	[blueMinOnes release];
	[blueSecTens release];
	[blueSecOnes release];
	
	[greenTimeDot release];
	[greenMinTens release];
	[greenMinOnes release];
	[greenSecOnes release];
	[greenSecTens release];
	
	[greenNumbers release];
	[redNumbers release];
	[blueNumbers release];
	
	[stepTimer invalidate];
	[stepTimer release];
	
	[gpsTimer invalidate];
	[gpsTimer release];
	
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NEXT_WORKOUT_STEP" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//    UIDevice* device = [UIDevice currentDevice];
//    
//    backgroundSupported = NO;
//    if ([device respondsToSelector:@selector(isMultitaskingSupported)])
//	{
//        backgroundSupported = device.multitaskingSupported;
//	}

	// gps enabled by user settings
//	if ([app.userData useGPS] && [c25kAppDelegate gpsEnabledDevice])
	{
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	}

	actionButtonText.text = @"Start";
	
	// init the music control view
//	self.musicControlView = [[MusicControlView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [MusicControlView getViewHeight], [MusicControlView getViewWidth], [MusicControlView getViewHeight])];
//	self.musicControlView.audioController = app.audCtrl;
//	app.audCtrl.delegate = self.musicControlView;
//	[self.view addSubview:musicControlView];
	
	// reset the progress bar
	self.totalTimeExercising		= 0;
	
	// set initial state
	state = WEV_GetReady;
	
	[self setButtonsForState];

	audioHalfwayOnce = FALSE;
	audioEncourageOnce = FALSE;

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustTimeForForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.previousButton = nil;
	self.nextButton = nil;
	self.actionButton = nil;
	self.actionButtonText = nil;
	self.stepCommand = nil;
	self.stepNext = nil;
	self.stepNextExercise = nil;
	self.timeLeftText = nil;
	
	self.doneButton = nil;
	self.doneText = nil;
	self.startCompleteButton = nil;
	self.startCompleteCommand = nil;
	self.startCompleteText = nil;
	
	self.locationManager.delegate = nil;
	self.gpsButton = nil;
	
//	self.tempXUpBtn = nil;
//	self.tempXDownBtn = nil;
//	self.tempYUpBtn = nil;
//	self.tempYDownBtn = nil;
//	self.tempIdxUpBtn = nil;
//	self.tempIdxDownBtn = nil;
//	
//	self.musicControlView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)crossFadeBackgroundsComplete
{
	self.startCompleteCommand.text = @"Workout Complete!";
	self.startCompleteText.text = @"CONTINUE";
}

- (void)crossFadeBackgrounds
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.00f];
	if (startCompleteBkgd.alpha > 0.9f)
	{
		stepBkgd.alpha			= 1;
//		musicControlView.alpha	= 1;
		stepCommand.alpha		= 1;
		actionButton.alpha		= 1;
		actionButtonText.alpha	= 1;
		doneButton.alpha		= 1;
		doneText.alpha			= 1;
		stepNext.alpha			= 1;
		stepNextExercise.alpha	= 1;
		nextButton.alpha		= 1;
		timeLeftText.alpha		= 1;
		blueTimeDot.alpha		= 1;
		greenTimeDot.alpha		= 1;
		greenMinTens.alpha		= 1;
		greenMinOnes.alpha		= 1;
		greenSecTens.alpha		= 1;
		greenSecOnes.alpha		= 1;
		blueMinTens.alpha		= 1;
		blueMinOnes.alpha		= 1;
		blueSecTens.alpha		= 1;
		blueSecOnes.alpha		= 1;

		startCompleteButton.alpha	= 0;
		startCompleteText.alpha		= 0;
		startCompleteBkgd.alpha		= 0;
		startCompleteCommand.alpha	= 0;
	}
	else
	{
		stepBkgd.alpha			= 0;
//		musicControlView.alpha	= 0;
		stepCommand.alpha		= 0;
		
		// NOTE: hide the action buttons on complete because
		//  the screen cross fades out and the button is ultimately not
		//  selectable.  if this screen is reused, would need to consider
		//  when/how to unhide them - but this is not the case for now.
//		actionButton.alpha		= 0;
//		actionButtonText.alpha	= 0;
		doneButton.alpha		= 0;
		doneText.alpha			= 0;
		stepNext.alpha			= 0;
		stepNextExercise.alpha	= 0;
		nextButton.alpha		= 0;
		timeLeftText.alpha		= 0;
		blueTimeDot.alpha		= 0;
		greenTimeDot.alpha		= 0;
		greenMinTens.alpha		= 0;
		greenMinOnes.alpha		= 0;
		greenSecTens.alpha		= 0;
		greenSecOnes.alpha		= 0;
		blueMinTens.alpha		= 0;
		blueMinOnes.alpha		= 0;
		blueSecTens.alpha		= 0;
		blueSecOnes.alpha		= 0;
		
		for (int i=0; i<[trackCircleImageViewList count]; ++i)
		{
			UIImageView *iv = [trackCircleImageViewList objectAtIndex:i];
			iv.alpha = 0;
		}
		
		startCompleteButton.alpha	= 1;
		startCompleteText.alpha		= 1;
		startCompleteBkgd.alpha		= 1;
		startCompleteCommand.alpha	= 1;
	}
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(crossFadeBackgroundsComplete)];
	[UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
	
	if (state == WEV_GetReady)
	{
		// get total workout time (s)
//		WorkoutItem *wItem = [app.appData.workoutData.workoutItems safeObjectAtIndex:workoutIndex];
		totalSecondsLeft = 60; // [wItem getTotalWorkoutTimeInSeconds];
		expectedExerciseDuration = totalSecondsLeft;
		
		// set the audio player with repeatThreshold
//		[app.audCtrl setRepeatFlag:[app.userData repeatAudio] withThreshold:expectedExerciseDuration];

		// reset the list of locations
//		UserWorkoutLog *uwl = [app.userData userWorkoutLogWithIndex:workoutIndex];

        // NSLog(@"Workout state = %d", uwl.state);

//		[uwl clearLocationList];

		// set title
		self.navigationItem.title = @"W1D1"; //wItem.name;

		self.startCompleteCommand.text = @"GET READY!";
		self.startCompleteText.text = @"START";
		
//		UINavigationController *navCtrl = self.navigationController;
//		self.musicControlView.navController = navCtrl;
		
		// start at the beginning
		if (!audioBeginWorkout)
		{
			audioBeginWorkout = TRUE;
			[self setWorkoutStep:0];
		}

		// fire up the GPS system... 
//		if ([app.userData useGPS] && [c25kAppDelegate gpsEnabledDevice])
		{
			// set image here in case we've lost signal (rather than when view loads)
			[self.gpsButton setImage:[UIImage imageNamed:@"assets/img/timer/gps/gps_red.png"] forState:UIControlStateNormal];
            
//          [mapButton setImage:[UIImage imageFromResource:@"assets/img/journal/btn_map"] forState:UIControlStateNormal];
//          [mapButton setImage:[UIImage imageFromResource:@"assets/img/journal/btn_map_press"] forState:UIControlStateHighlighted];
//			
//			[self startGPS];	// to set image color
//          [self stopGPS];		// so that tracking doesn't begin until workout begins
		}
	}

	// set the audio delegate for track change info
//	app.audCtrl.delegate = self.musicControlView;
}

- (void)viewWillDisappear:(BOOL)animated
{
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//	app.audCtrl.delegate = nil;
}

- (void)updateTrack
{
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
	
	const float pct = fabsf((float)totalSecondsLeft / (float)expectedExerciseDuration);
//	
//	if (pct < 0.5f && pct > 0.4f // make sure that halfway audio cue only fires at appropriate time (may be coming out of background)
//		&& audioHalfwayOnce == FALSE 
//		&& [app.userData halfwayAudioCue]
//		&& ![app.audCtrl isSoundPlaying]
//		)
//	{
//		audioHalfwayOnce = TRUE;
//		[[app.appData getTrainer:app.userData.trainerType] playClipOfTrainerType:kTAT_Halfway withController:app.audCtrl withVibration:app.userData.vibrationCue];
//	}
//	
//	if (pct < 0.35f
//		&& workoutIndex > 5		// post week 2
//		&& audioEncourageOnce == FALSE
//		&& ![app.audCtrl isSoundPlaying]
//		)
//	{
//		audioEncourageOnce = TRUE;
//		
//		int type = kTAT_Encourage;
//		// 50% we play a motivate, 50% encourage
//		if (50 < rand() % 100)
//		{
//			type = kTAT_Motivate;
//		}
//		
//		[[app.appData getTrainer:app.userData.trainerType] playClipOfTrainerType:type withController:app.audCtrl withVibration:NO];
//	}
	
	NSInteger segments = NUM_TRACK_SEGMENTS	- pct * NUM_TRACK_SEGMENTS;
	for (int i=0; i<[trackCircleImageViewList count]; ++i)
	{
		UIImageView *iv = [trackCircleImageViewList objectAtIndex:i];
		if (i < segments)
			iv.alpha = 1.0f;
		else
			iv.alpha = 0.0f;
	}	
}

- (void)setWorkoutStep:(NSInteger)step
{
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
	
	if (WEV_Complete == state)
		return;
	
	currentStep = step;
	// TODO: FIXME!!!!
	if (currentStep < 2) // [exerciseList count])
	{
//		UIColor *redColor   = [UIColor colorWithRed:239.0f/255.0f green:28.0f/255.0f blue:37.0f/255.0f alpha:1.0f];
		UIColor *greenColor = [UIColor colorWithRed:177.0f/255.0f green:254.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
		
		// show step details in the controls
//		ExerciseItem *exDetails = [exerciseList objectAtIndex:currentStep];
       
		//NSLog(@"starting step %i at %@: Duration: %i",step,[NSDate date], exDetails.exerciseDurationSeconds);
		
        //set up local notifications for the entire workout
//        if (currentStep==1) {
//            workoutStartDate=[[NSDate alloc] init];
//            [self performSelectorInBackground:@selector(resetLocalNotifications) withObject:nil];
//            
//            if ([app.userData useGPS] && [c25kAppDelegate gpsEnabledDevice]) {
//                [self startGPS];
//            }
//        }
        
		// name
		stepCommand.text = @"Walk"; // exDetails.exerciseName;
//		if (exDetails.exerciseType == kRun || exDetails.exerciseType == kJog)
//			stepCommand.textColor = redColor;
//		else
			stepCommand.textColor = greenColor;
	
		// play trainer audio for this step (if not running in background, where audio from local notification will fire)
//        if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive) {
//            [[app.appData getTrainer:app.userData.trainerType] playClipOfExerciseType:exDetails.exerciseType withController:app.audCtrl withVibration:app.userData.vibrationCue];
//        }
        
//        if (currentStep==1) {//add walk clip
//            app.audCtrl.sfxPlayer.delegate=self;
//        }
		
		// duration
		currentSeconds = workout.duration; // exDetails.exerciseDurationSeconds;		// = 3;
		[self updateTimerDisplay];
		
		// next step
		if (currentStep + 1 <= /*[exerciseList count]*/ 1 - 1)
		{
//			ExerciseItem *exDetailsNext = [exerciseList safeObjectAtIndex:currentStep+1];
//			stepNext.text = @"Next: ";
//			
//			int sec = exDetailsNext.exerciseDurationSeconds % 60;
//			int min = (exDetailsNext.exerciseDurationSeconds - sec) / 60;
//			stepNextExercise.text = [NSString stringWithFormat:@"%@ %d:%0.2d", exDetailsNext.exerciseName, min, sec];
//			if (exDetailsNext.exerciseType == kRun || exDetailsNext.exerciseType == kJog)
//				stepNextExercise.textColor = redColor;
//			else
//				stepNextExercise.textColor = greenColor;
		}
		else
		{
			stepNext.text = @"";
			stepNextExercise.text = @"";
		}
	}
	// workout complete
	else
	{
		[self invalidateTimer];
		
		[self stopGPS];
		
		[self shutdownMusicPlayback];
		
		// disable music control
//		self.musicControlView.enabled = NO;
		
		stepCommand.text			= @"Complete!";
		currentSeconds				= 0;
		totalSecondsLeft			= 0;
		
		[self updateTrack];

//		[[app.appData getTrainer:app.userData.trainerType] playClipOfTrainerType:kTAT_Complete withController:app.audCtrl withVibration:app.userData.vibrationCue];
		
		state = WEV_Complete;

		// cross-fade background views
		[self crossFadeBackgrounds];

		actionButtonText.text = @"COMPLETE";
		
		// NOTE: hide the action buttons on complete because
		//  the screen cross fades out and the button is ultimately not
		//  selectable.  if this screen is reused, would need to consider
		//  when/how to unhide them - but this is not the case for now.
		actionButtonText.hidden = true;
		actionButton.hidden = true;
		
//		userLog						= [app.userData userWorkoutLogWithIndex:workoutIndex];
//		userLog.state				= kWorkoutComplete;
//		userLog.workoutIndex		= workoutIndex;
//		userLog.trainerType			= app.userData.trainerType;
//		[userLog setDate:[NSDate date]];
//		[userLog computeDistanceAndPaceWithDuration:totalTimeExercising];
//		
//		[app saveUserData:nil];
//		
//		[FlurryAnalytics logEvent:@"WORKOUT_COMPLETE" 
//			 withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
//							 app.userData.activeGUID,									 @"activeGUID",
//							 [NSString stringWithFormat:@"%d", userLog.workoutIndex],	 @"workoutIndex",
//							 [userLog dateAsString],									 @"workoutDate",
//							 [[app.appData getTrainer:app.userData.trainerType] getName],@"trainerType",
//							 [NSNumber numberWithFloat:[userLog distance]],				 @"workoutDistance",
//							 [NSNumber numberWithFloat:[userLog pace]],					 @"workoutPace",
//							 nil]
//		 ];
//		
//		// did something interesting happen?
//		[self achievementViewDismissed];
	}
}
-(void)playWalkClip{
//    const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//    [[app.appData getTrainer:app.userData.trainerType] playClipOfExerciseType:kWalk withController:app.audCtrl withVibration:app.userData.vibrationCue];
}
- (void)shutdownLocationManager
{
	// shutdown position updates
	if (self.locationManager)
	{
		[self.locationManager stopUpdatingLocation];
		self.locationManager.delegate = nil;
	}
	
	self.gpsButton.hidden = YES;
}

- (void)shutdownMusicPlayback
{
//	[self.musicControlView stopMusic];
}

- (void)getDigits:(NSInteger)val tens:(NSInteger*)tens ones:(NSInteger*)ones
{
	*tens = 0;
	*ones = 0;
	
	while (val >= 10)
	{
		++(*tens);
		val -= 10;
	}
	
	while (val > 0)
	{
		++(*ones);
		val--;
	}
}


- (void)updateTimerDisplay
{
	int sec = currentSeconds % 60;
	int min = (currentSeconds - sec) / 60;

	NSInteger minTens, minOnes, secTens, secOnes;
	minTens = minOnes = secTens = secOnes = 0;
	
	[self getDigits:sec tens:&secTens ones:&secOnes];
	[self getDigits:min tens:&minTens ones:&minOnes];
	//NSLog(@"%d%d:%d%d", minTens, minOnes, secTens, secOnes);
	{
//		ExerciseItem *exDetails = [exerciseList safeObjectAtIndex:currentStep];
//		if (exDetails.exerciseType == kJog || exDetails.exerciseType == kRun)
//		{
//			greenMinTens.image = [redNumbers safeObjectAtIndex:minTens];
//			greenMinOnes.image = [redNumbers safeObjectAtIndex:minOnes];
//			greenSecTens.image = [redNumbers safeObjectAtIndex:secTens];
//			greenSecOnes.image = [redNumbers safeObjectAtIndex:secOnes];
//
//			greenTimeDot.image = [UIImage imageNamed:@"assets/img/timer/red/dots.png"];
//		}
//		else
		{
			greenMinTens.image = [greenNumbers objectAtIndex:minTens];
			greenMinOnes.image = [greenNumbers objectAtIndex:minOnes];
			greenSecTens.image = [greenNumbers objectAtIndex:secTens];
			greenSecOnes.image = [greenNumbers objectAtIndex:secOnes];
			
			greenTimeDot.image = [UIImage imageNamed:@"assets/img/timer/green/dots.png"];
		}
	}
	
	{
		int totSec = abs(totalSecondsLeft % 60);
		int totMin = abs((totalSecondsLeft - totSec) / 60);
		
		minTens = minOnes = secTens = secOnes = 0;
		[self getDigits:totSec tens:&secTens ones:&secOnes];
		[self getDigits:totMin tens:&minTens ones:&minOnes];
		
		blueMinTens.image  = [blueNumbers objectAtIndex:minTens];
		blueMinOnes.image  = [blueNumbers objectAtIndex:minOnes];
		blueSecTens.image  = [blueNumbers objectAtIndex:secTens];
		blueSecOnes.image  = [blueNumbers objectAtIndex:secOnes];
	}
	
	[self updateTrack];
}

#pragma mark - MapKit

#define GPS_DEFAULT_HORIZ_ACC			 (50.0f)
#define GPS_DEFAULT_TIME_DELTA			 (5.0f)

static bool gpsReady = false;

static float minHorizontalAccuracy	= GPS_DEFAULT_HORIZ_ACC;
static float minTimeInterval		= GPS_DEFAULT_TIME_DELTA;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"New GPS data");

	// quick reject of potentially invalid location data
	if (newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > minHorizontalAccuracy)
	{
		//NSLog(@"GPS data rejected: horizontal accuracy out of range");
		[self.gpsButton setImage:[UIImage imageNamed:@"assets/img/timer/gps/gps_yellow.png"] forState:UIControlStateNormal];
		return;
	}
	
	// wait for something fairly recent
	NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
	if (locationAge > minTimeInterval)
	{
		//NSLog(@"GPS data rejected: data too old");
		[self.gpsButton setImage:[UIImage imageNamed:@"assets/img/timer/gps/gps_yellow.png"] forState:UIControlStateNormal];
		return;
	}
	
	// negative speed indicates poor location data
	if (newLocation.speed < 0.0f)
	{
		//NSLog(@"GPS data rejected: negative speed");
		[self.gpsButton setImage:[UIImage imageNamed:@"assets/img/timer/gps/gps_yellow.png"] forState:UIControlStateNormal];
		return;
	}
	
	// past all quick reject cases, we have a valid position!
	if (!gpsReady)
	{
		gpsReady = true;
		
		// we've locked on, so we can stop relaxing tolerances
		if (gpsTimer != nil)
		{
			[gpsTimer invalidate];
			gpsTimer = nil;
		}
		
//		// send one positional message to Flurry
//		[FlurryAnalytics setLatitude:newLocation.coordinate.latitude 
//						   longitude:newLocation.coordinate.longitude 
//				  horizontalAccuracy:newLocation.horizontalAccuracy 
//					verticalAccuracy:newLocation.verticalAccuracy];
//		
//		[FlurryAnalytics logEvent:@"GPS_LOCK" 
//				   withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
//								   [NSNumber numberWithFloat:minHorizontalAccuracy],		@"minAccuracy",
//								   nil]];
	}
	
	// store the new location
	if (newLocation)
	{
		// should we continue to record points if someone isn't moving (much)?
		if ((oldLocation.coordinate.latitude  != newLocation.coordinate.latitude) ||
			(oldLocation.coordinate.longitude != newLocation.coordinate.longitude))
		{
//			c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//			UserWorkoutLog *uwl = [app.userData userWorkoutLogWithIndex:workoutIndex];
//			
//			[self.gpsButton setImage:[UIImage imageNamed:@"assets/img/timer/gps/gps_green.png"] forState:UIControlStateNormal];
//
//			//[uwl.locationList addObject:newLocation];
//            [uwl.routeData appendLocation:newLocation];
//            
//			DLog(@"%@", [newLocation description]);
//			DLog(@"hacc: %f - vacc: %f - spd: %f", [newLocation horizontalAccuracy], [newLocation verticalAccuracy], [newLocation speed]);
		}
        else
		{
			//NSLog(@"Location has not changed");
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if ([error code] == kCLErrorDenied)
	{
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"Please turn on Location Services in the device Settings to enable GPS functionality."  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[av show];
		[av release];
		
		// disable location polling for now
		[self shutdownLocationManager];
	}
}

- (void)startGPS
{
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
	
//	if ([app.userData useGPS] && [c25kAppDelegate gpsEnabledDevice])
	{
		if (gpsEnabled == FALSE)
		{
			gpsReady			= false;
			gpsEnabled			= TRUE;
			gpsButton.hidden	= FALSE;
//          mapButton.hidden    = TRUE;  // keep hidden until view map during workout enabled in next version (1.1.1)
			
			self.locationManager.delegate = self;
			[self.locationManager startUpdatingLocation];
			
			if (gpsTimer == nil)
			{
				gpsTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(gpsTimerExpiredEvent:) userInfo:nil repeats:YES];
			}
		}
	}
//	else
//	{
//		[self stopGPS];
//	}
}


- (void)stopGPS
{
	gpsReady		 = false;
	gpsEnabled		 = FALSE;
	gpsButton.hidden = TRUE;
//    mapButton.hidden = TRUE;
	
	minTimeInterval		  = GPS_DEFAULT_TIME_DELTA;
	minHorizontalAccuracy = GPS_DEFAULT_HORIZ_ACC;
	
	[self shutdownLocationManager];
	
	if (gpsTimer != nil)
	{
		[gpsTimer invalidate];
		gpsTimer = nil;
	}	
    
//    c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//    UserWorkoutLog *uwl  = [app.userData userWorkoutLogWithIndex:workoutIndex];
//    
//    [uwl.routeData endUpdate];
}

#pragma mark - Button State Management

- (void)setButtonsForState
{
	switch (state)
	{
		case WEV_GetReady:
		case WEV_Complete:
			previousButton.hidden	= YES;
			nextButton.hidden		= YES;
			
			stepNext.hidden			= YES;
			break;
			
		case WEV_InProgress:
		case WEV_Paused:
			if (currentStep > 1)
				previousButton.hidden = NO;
			else
				previousButton.hidden = YES;

// always show the next button
//			if (currentStep + 1 <= [exerciseList count] - 1)
				nextButton.hidden = NO;
//			else
//				nextButton.hidden = YES;
			
			stepNext.hidden			= NO;
			break;
	}
}

- (NSString*)getLogMessage
{
//	const c25kAppDelegate *app	= [c25kAppDelegate appDelegate];
//	BOOL isMetric = ([app.appData isMetric] || [app.userData useMeters]);
//
//    if ((TARGET_IPHONE_SIMULATOR || [userLog.routeData hasData]) && userLog.distance > 0.0f && userLog.pace > 0.0f)
//	{
//		NSString *distanceText;
//		NSString *paceText;
//		
//		float localPace = (isMetric == YES) ? userLog.pace / MILE_PER_KM : userLog.pace;
//		
//		int sec = (int)(localPace) % 60;
//		int min = (localPace - sec) / 60;
//
//		if (isMetric)
//		{
//			distanceText = [NSString stringWithFormat:@"%3.2f km", userLog.distance / METER_PER_MILE / 1000.0f];
//			paceText	 = [NSString stringWithFormat:@"%02d:%02d per km", min, sec];
//		}
//		else
//		{
//			distanceText = [NSString stringWithFormat:@"%3.2f miles", userLog.distance];
//			paceText	 = [NSString stringWithFormat:@"%02d:%02d per mile", min, sec];
//		}
//		
//		return [NSString stringWithFormat:@"I just finished %@ of Active.com's Couch-to-5K program going %@ at %@.", 
//					  [[app.appData.workoutData.workoutItems safeObjectAtIndex:workoutIndex] name], distanceText, paceText];
//	}
//	else
//	{
//		return [NSString stringWithFormat:@"I just finished %@ of Active.com's Couch-to-5K program!", 
//					  [[app.appData.workoutData.workoutItems safeObjectAtIndex:workoutIndex] name]];
//	}
//	
	
	return @"";
}

- (IBAction)nextButtonPressed:(id)sender
{	
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
//	userLog.skippedInterval = TRUE;
  
	// advance time
	totalSecondsLeft	-= currentSeconds;
	
    // back date start time, so that adjustTimeForForeground calculates current step
    workoutStartDate = [[workoutStartDate dateByAddingTimeInterval:-currentSeconds] retain];
	
	//NSLog(@"(%d) totalSecondsLeft: %d (currentSeconds: %d)", currentStep, totalSecondsLeft, currentSeconds);
	
	[self setWorkoutStep:currentStep + 1];
	[self setButtonsForState];
    
    //reset local notifications for new start time    
//    [self performSelectorInBackground:@selector(resetLocalNotifications) withObject:nil];
}

- (IBAction)previousButtonPressed:(id)sender
{
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//	const c25kAppDelegate *app	= [c25kAppDelegate appDelegate];
//	const WorkoutItem *wItem	= [app.appData.workoutData.workoutItems safeObjectAtIndex:workoutIndex];
	totalSecondsLeft			= expectedExerciseDuration - 60; // [wItem getExerciseWorkoutTimeInSeconds:currentStep - 1];
    
    // back date start time, so that adjustTimeForForeground calculates current step
    NSDate *workoutEndDate = [[NSDate date] dateByAddingTimeInterval:+totalSecondsLeft];
    workoutStartDate = [[workoutEndDate dateByAddingTimeInterval:-expectedExerciseDuration] retain];
	
	//NSLog(@"(%d) totalSecondsLeft: %d (currentSeconds: %d)", currentStep-1, totalSecondsLeft, currentSeconds);
	
	[self setWorkoutStep:currentStep - 1];
	[self setButtonsForState];
    
    //reset local notifications for new start time    
//    [self performSelectorInBackground:@selector(resetLocalNotifications) withObject:nil];
}

- (IBAction)actionButtonPressed:(id)sender
{
//	const c25kAppDelegate *app	= [c25kAppDelegate appDelegate];

	const WEV_State oldState = state;
	WEV_State newState = WEV_Complete;
	
	if (oldState == WEV_GetReady)
	{
		newState = WEV_InProgress;
		
		actionButtonText.text = @"PAUSE";
		
		// cross-fade background views
		[self crossFadeBackgrounds];
		
		[self setupTimer];
		
		[self setWorkoutStep:currentStep+1];
		
		// auto-start the music
//		if ([app.audCtrl getMusicPlaybackState] != MPMusicPlaybackStatePlaying && [app.audCtrl musicCollectionIsSet])
//		{
//			[app.audCtrl playMusic];
//		}
	}
	else if (oldState == WEV_InProgress)
	{
		newState = WEV_Paused;
		
		actionButtonText.text = @"RESUME";
		
		[self invalidateTimer];
        
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
	}
	else if (oldState == WEV_Paused)
	{
		newState = WEV_InProgress;
		
		actionButtonText.text = @"PAUSE";
		
		[self setupTimer];
//        [self performSelectorInBackground:@selector(resetLocalNotifications) withObject:nil];
	}
	else if (oldState == WEV_Complete)
	{
		newState = WEV_Complete;
		
		actionButtonText.text = @"COMPLETE";
		
		// NOTE: hide the action buttons on complete because
		//  the screen cross fades out and the button is ultimately not
		//  selectable.  if this screen is reused, would need to consider
		//  when/how to unhide them - but this is not the case for now.
		actionButtonText.hidden = true;
		actionButton.hidden = true;
		
		// cleanup
		[self invalidateTimer];

		[self stopGPS];
		
		[self shutdownMusicPlayback];
		
//		const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//		
//		userLog						= [app.userData userWorkoutLogWithIndex:workoutIndex];
//		userLog.state				= kWorkoutComplete;
//		userLog.workoutIndex		= workoutIndex;
//		userLog.trainerType			= app.userData.trainerType;
//		[userLog setDate:[NSDate date]];
//		[userLog computeDistanceAndPaceWithDuration:totalTimeExercising];
//		
//		[app saveUserData:nil];
//		
//		[FlurryAnalytics logEvent:@"WORKOUT_COMPLETE" 
//			 withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
//							 app.userData.activeGUID,									 @"activeGUID",
//							 [NSString stringWithFormat:@"%d", userLog.workoutIndex],	 @"workoutIndex",
//							 [userLog dateAsString],									 @"workoutDate",
//							 [[app.appData getTrainer:app.userData.trainerType] getName],@"trainerType",
//							 [NSNumber numberWithFloat:[userLog distance]],				 @"workoutDistance",
//							 [NSNumber numberWithFloat:[userLog pace]],					 @"workoutPace",
//							 nil]
//		 ];
//		
//		// did something interesting happen?
//		[self achievementViewDismissed];
		
		
		[self.navigationController dismissModalViewControllerAnimated:YES];

	}

	state = newState;
	[self setButtonsForState];
}

- (void)handleWorkoutComplete
{
//    NSLog(@"Finished workout %@",[ NSDate date]);
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//	NSString *logMessage = [self getLogMessage];
	
	// record that we've completed the workout
//	if ([app.userData firstLaunch] && [app isOnline])
//	{
//		app.userData.firstLaunch = FALSE;
//		[app saveUserData:nil];
//		
//		// show the active trainer pitch
//		ActiveTrainerView *atv = [[ActiveTrainerView alloc] initWithNibName:@"ActiveTrainerView" bundle:nil];
//		atv.userWorkoutLog	   = userLog;
//		atv.logMessage		   = logMessage;
//		atv.journalTitleText   = [NSString stringWithString:[[app.appData.workoutData.workoutItems safeObjectAtIndex:workoutIndex] name]];
//		
//		[self.navigationController pushViewController:atv animated:YES];
//		[atv release];
//	}
//	else if ([app isOnline])
//	{
//		// if we have a valid GUID, log the workout complete
//		if ([app.userData.activeGUID length])
//		{
//			app.activeTrainer.delegate = self;
//			[app.activeTrainer logWorkout:workoutIndex+1 
//								 withUser:[app.userData activeGUID] 
//							 withDistance:userLog.distance 
//								 withPace:userLog.pace];
//		}
//		else
//		{
//			[self requestFinished:kLogWorkout withResult:kUnknownError];
//		}
//	}
//	else
//	{
//		// show summary / comment window
//		JournalDetailView *jdv	= [[JournalDetailView alloc] initWithNibName:@"JournalDetailView" bundle:nil];
//		jdv.isModal				= YES; 
//		jdv.userWorkoutLog		= userLog;
//		jdv.prepopulatedLogMessage = logMessage;
//		jdv.titleText			= [NSString stringWithString:[[app.appData.workoutData.workoutItems safeObjectAtIndex:workoutIndex] name]];
//		
//		
//		[self.navigationController pushViewController:jdv animated:YES];
//		[jdv release];
//	}
}

- (void)doneButtonPressed:(id)sender
{
	if (WEV_Complete == state)
		return;
//    
//    UIAlertView *alert=[UIAlertView alloc];
//    [alert initWithTitle:@"Quit Workout?" message:@"You are leaving the workout before you have completed it. Which of the following do you want to do?" delegate:self cancelButtonTitle:@"Return to Workout" otherButtonTitles:@"Quit Workout", @"Go to Trainer Settings", nil];
//    [alert show];
//    [alert release];
//	
	
	[self invalidateTimer];
	
	[self stopGPS];
	
	[self shutdownMusicPlayback];
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        [self invalidateTimer];

        [self stopGPS];
	
        [self shutdownMusicPlayback];
    
        [self dismissModalViewControllerAnimated:YES];
    
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
       // workoutPaused=YES;
    } 
	else if (buttonIndex==2) 
	{
//        SettingsView *vc =[[SettingsView alloc] init];
//        vc.navigationItem.title=@"Trainer Settings";
//        vc.launchFromWorkout=TRUE;
//        [self.navigationController setNavigationBarHidden:NO];
//        [self.navigationController pushViewController:vc animated:YES];
//        [vc release];
    }
}

#pragma mark - AchievementViewDelegate

- (void)achievementViewDismissed
{
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//	
//	// did something else happen?
//	AchievementType at = [app.appData.achievementData checkForNewAchievementWithUserData:app.userData];
//	if (at != kAchievement_None)
//	{
//		// add the achievement to the user's achievement log so we don't trigger this again
//		UserAchievementLog *ual = [[UserAchievementLog alloc] init];
//		ual.achievementID = at;
//		[app.userData.achievementLog5K addObject:ual];
//		[app saveUserData:nil];
//		[ual release];
//
//		// show the view
//		[app showAchievement:at withDelegate:self];
//	}
//	else
	{
		// deal with end of workout transitions
		[self handleWorkoutComplete];
	}
}

#pragma mark - Timer Methods

- (void)invalidateTimer
{
	if (stepTimer != nil)
	{
		[stepTimer invalidate];
		stepTimer = nil;
	}
}

- (void)setupTimer
{
	if (stepTimer == nil)
	{
		stepTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerExpiredEvent:) userInfo:nil repeats:YES];
	}
	else
	{
		NSAssert(0, @"setupTimer called with valid timer...");
	}
}


- (void)timerExpiredEvent:(NSTimer*)t
{
	currentSeconds		-= 1;
	totalSecondsLeft	-= 1;
	
	totalTimeExercising += 1;
	
	if (currentSeconds > 0)
	{
		[self updateTimerDisplay];
	}
	else
	{
		[self setWorkoutStep:currentStep + 1];
		[self setButtonsForState];
	}
}

- (void)gpsTimerExpiredEvent:(NSTimer*)t
{
	minHorizontalAccuracy += 5.0f;		// slowly increase acceptable GPS radius
	minTimeInterval		  += 0.1f;		// slowly increase time interval
}

#pragma mark - Handle return to foreground for backgrounded app
-(void)adjustTimeForForeground:(NSNotification *)notif
{
//    //calculate new time for timer based on time started exercise and current time
//    NSDate *now=[NSDate date];
//    NSInteger calcTimeExercising= (int) [now timeIntervalSinceDate:workoutStartDate];
//    totalSecondsLeft=expectedExerciseDuration- calcTimeExercising;
//    //find current step based on total time exercising
//    int timeSoFar=0;
// 
//    int completedStep = -1;
//    UIColor *redColor = [UIColor colorWithRed:239.0f/255.0f green:28.0f/255.0f blue:37.0f/255.0f alpha:1.0f];
//	UIColor *greenColor = [UIColor colorWithRed:177.0f/255.0f green:254.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
//            
//    for (ExerciseItem *workoutStep in exerciseList) {
//        timeSoFar+=workoutStep.exerciseDurationSeconds;
//        if (calcTimeExercising>timeSoFar) {           
//            completedStep++;     
//        } else {
//            currentSeconds=timeSoFar-calcTimeExercising; 
//            currentStep=completedStep+1; 
//         
//            stepCommand.text = workoutStep.exerciseName;
//            
//            if (workoutStep.exerciseType == kRun || workoutStep.exerciseType == kJog)
//                stepCommand.textColor = redColor;
//            else
//                stepCommand.textColor = greenColor;
//            
//            //next step
//            if (currentStep + 1 <= [exerciseList count] - 1)
//            {
//                ExerciseItem *exDetailsNext = [exerciseList safeObjectAtIndex:currentStep+1];
//                stepNext.text = @"Next: ";
//                
//                int sec = exDetailsNext.exerciseDurationSeconds % 60;
//                int min = (exDetailsNext.exerciseDurationSeconds - sec) / 60;
//                stepNextExercise.text = [NSString stringWithFormat:@"%@ %d:%0.2d", exDetailsNext.exerciseName, min, sec];
//                if (exDetailsNext.exerciseType == kRun || exDetailsNext.exerciseType == kJog)
//                    stepNextExercise.textColor = redColor;
//                else
//                    stepNextExercise.textColor = greenColor;
//            }
//            else
//            {
//                stepNext.text = @"";
//                stepNextExercise.text = @"";
//            }
//            [self setButtonsForState];
//            return;
//        }
//
//    } 
//    if (totalSecondsLeft<=0) {
//        //workout completed while app was backgrounded
//        [self setWorkoutStep:currentStep+1];
//    } 
 
}

-(void)resetLocalNotifications
{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
//    if (backgroundSupported) 
//	{
//        const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//        
//        [[UIApplication sharedApplication] cancelAllLocalNotifications];
//        NSDate *lastStepEndedDate=[NSDate date];
//		
//		// don't schedule local notification until start 
//        if (currentStep > 0) 
//		{
//            for (int i=currentStep; i<[exerciseList count]; i++) 
//			{
//                UILocalNotification *nextEventNotification = [[UILocalNotification alloc] init];
//                ExerciseItem *workoutStep = [exerciseList objectAtIndex:i];
//
//                nextEventNotification.fireDate = lastStepEndedDate;
//                nextEventNotification.timeZone = [NSTimeZone defaultTimeZone];
//				
//                int workoutMin = trunc(workoutStep.exerciseDurationSeconds / 60);
//                int workoutSec = workoutStep.exerciseDurationSeconds % 60;
//                nextEventNotification.alertBody = [NSString stringWithFormat:@"Workout step complete.\nNow %@ ! (for %i:%02d)", workoutStep.exerciseName, workoutMin, workoutSec];
//                NSString *pathForSound=[[app.appData getTrainer:app.userData.trainerType] getPathForClipOfExerciseType:workoutStep.exerciseType];
//                //nextEventNotification.soundName=UILocalNotificationDefaultSoundName; //older OS cannot play sound?
//                nextEventNotification.soundName=[NSString stringWithFormat:@"%@.caf",pathForSound];  
//                NSDictionary *userInfoDict=[[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:lastStepEndedDate  ] forKeys:[NSArray arrayWithObject:@"lastStepStartDate"]];
//                nextEventNotification.userInfo=userInfoDict;
//                NSDate *nextNotificationDate=[lastStepEndedDate dateByAddingTimeInterval:workoutStep.exerciseDurationSeconds];
//                lastStepEndedDate=nextNotificationDate;
//                [[UIApplication sharedApplication] scheduleLocalNotification:nextEventNotification];
//                NSLog(@"scheduling local notification for step %i %@, after %i:%02d", i, nextNotificationDate, workoutMin, workoutSec);
//                [nextEventNotification release];
//            }
//            // add notification for completed workout
//            UILocalNotification *nextEventNotification=[[UILocalNotification alloc] init];
//            nextEventNotification.fireDate=lastStepEndedDate;
//            nextEventNotification.timeZone=[NSTimeZone defaultTimeZone];
//            nextEventNotification.alertBody=[NSString stringWithFormat:@"Workout complete!"];
//            NSString *pathForSound=[[app.appData getTrainer:app.userData.trainerType] getPathForClipOfTrainerType:kTAT_Complete];
//            nextEventNotification.soundName=[NSString stringWithFormat:@"%@.caf",pathForSound];  
//            NSDictionary *userInfoDict=[[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:lastStepEndedDate  ] forKeys:[NSArray arrayWithObject:@"lastStepStartDate"]];
//            nextEventNotification.userInfo=userInfoDict;
//
//            [[UIApplication sharedApplication] scheduleLocalNotification:nextEventNotification];
//        }
//    }
//    [pool release];
}

#pragma mark - Active Trainer Delegate

//- (void)requestFinished:(ActiveTrainerRequest)request withResult:(ActiveTrainerResult)result
//{
//	const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//
//	if (request == kLogWorkout)
//	{
//		if (result == kNoError)
//		{
//			userLog.activeWorkoutID = app.activeTrainer.activeTrainerDataResult.workoutID;
//			[app saveUserData:nil];
//		}
//	}
//	
//	app.activeTrainer.delegate = nil;
//	
//	// show summary / comment window
//	JournalDetailView *jdv	= [[JournalDetailView alloc] initWithNibName:@"JournalDetailView" bundle:nil];
//	jdv.isModal				= YES; 
//	jdv.userWorkoutLog		= userLog;
//	jdv.prepopulatedLogMessage = [self getLogMessage];
//	jdv.titleText			= [NSString stringWithString:[[app.appData.workoutData.workoutItems safeObjectAtIndex:workoutIndex] name]];
//	
//	
//	[self.navigationController pushViewController:jdv animated:YES];
//	[jdv release];
//}

#pragma mark -
#pragma mark AV Foundation delegate methods

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) appSoundPlayer successfully: (BOOL) flag 
{
//	if (currentStep==1) {
//        [self playWalkClip];
//    }
}
#pragma mark - view map
- (IBAction)mapButtonPressed:(id)sender
{
//    const c25kAppDelegate *app = [c25kAppDelegate appDelegate];
//    
//    JournalDetailMapView *jdmv = [[JournalDetailMapView alloc] initWithNibName:@"JournalDetailMapView" bundle:nil];
//    userLog = [app.userData userWorkoutLogWithIndex:workoutIndex];
//	[userLog setDate:[NSDate date]];
//    [userLog computeDistanceAndPaceWithDuration:totalTimeExercising];
//    jdmv.userWorkoutLog = userLog;
//    jdmv.userWorkoutLog.state=kWorkoutInProgress; 
//
//    jdmv.isModal = YES;
//    jdmv.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
//        
//    UINavigationController *navCtrl = [[[UINavigationController alloc] initWithRootViewController:jdmv] autorelease];
//    [self presentModalViewController:navCtrl animated:YES];
//	
//	[jdmv release];
}

@end
