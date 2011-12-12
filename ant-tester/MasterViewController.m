//
//  MasterViewController.m
//  ant-tester
//
//  Created by Jeremy Jessup on 12/11/11.
//  Copyright (c) 2011 The Active Network Inc. All rights reserved.
//

#import "MasterViewController.h"
#import "AppDelegate.h"
#import "PacketData.h"

@implementation MasterViewController
@synthesize detectAntDevices;
@synthesize heartMonitor;
@synthesize pedometer;
@synthesize spinner;
@synthesize heartRateConnection;
@synthesize footPodConnection;
@synthesize gkSession;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
	{
		self.title = NSLocalizedString(@"Master", @"Master");
    }
    return self;
}
							
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

	[detectAntDevices release];
	[heartMonitor release];
	[pedometer release];
	[spinner release];
	
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	hardwareConnector = [WFHardwareConnector sharedConnector];

    // register for HW connector notifications.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fisicaConnected) name:WF_NOTIFICATION_HW_CONNECTED object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fisicaDisconnected) name:WF_NOTIFICATION_HW_DISCONNECTED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:WF_NOTIFICATION_SENSOR_HAS_DATA object:nil];
	
	gkPickerCtrl = [[GKPeerPickerController alloc] init];
	gkPickerCtrl.delegate = self;
	gkPickerCtrl.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
	gkPeers = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	if (hardwareConnector.currentState == WF_HWCONN_STATE_CONNECTED)
	{
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Fisica Device" message:@"Connect the hardware and restart" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[av show];
		[av release];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - GK Stuff

- (IBAction)connectButtonPressed:(id)sender
{
	[gkPickerCtrl show];
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type{
	// Create a session with a unique session ID - displayName:nil = Takes the iPhone Name
	GKSession* session = [[GKSession alloc] initWithSessionID:@"com.active.ant-tester" displayName:nil sessionMode:GKSessionModePeer];
    return [session autorelease];
}

// Tells us that the peer was connected
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session{
	
	// Get the session and assign it locally
    self.gkSession = session;
    session.delegate = self;

	picker.delegate = nil;
    [picker dismiss];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	if(state == GKPeerStateConnected)
	{
		// Add the peer to the Array
		[gkPeers addObject:peerID];
		
		NSString *str = [NSString stringWithFormat:@"Connected with %@",[session displayNameForPeer:peerID]];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connected" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		// Used to acknowledge that we will be sending data
		[gkSession setDataReceiveHandler:self withContext:nil];
	}
}

// Function to receive data when sent from peer
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	NSData *d = [[NSMutableData alloc] initWithData:data];
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:d];
	
	PacketData *packet = [unarchiver decodeObjectForKey:@"PacketData"];

	if (packet.packetType == kHeartData)
	{
		peerHeartRate.text = [packet getObjectForKey:@"bpm"];
	}
	else if (packet.packetType == kFootData)
	{
		peerFootPod.text = [packet getObjectForKey:@"pace"];
	}
	
	[unarchiver finishDecoding];
	[unarchiver release];
	[d release];
	
	// do something with the data...
}

#pragma mark - WF Stuff

- (IBAction)detectAntDevicesButtonPressed:(id)sender
{
	// we'll detect the heart monitor and pedometer
	
	spinner.hidden = NO;
	[spinner startAnimating];
	
	[self performSelectorInBackground:@selector(handleSensorConnections) withObject:nil];
}

- (void)handleSensorConnections
{
	// get the current connection status.
	WFSensorConnectionStatus_t connState = WF_SENSOR_CONNECTION_STATUS_IDLE;

	for (int i=0; i<2; ++i)
	{
		WFSensorConnection *sc = nil;
		WFSensorType_t sensorType = (i==0) ? WF_SENSORTYPE_HEARTRATE : WF_SENSORTYPE_FOOTPOD;
		
		if (i == 0 && heartRateConnection != nil)
		{
			connState = heartRateConnection.connectionStatus;
		}
		else if (i == 1 && footPodConnection != nil)
		{
			connState = footPodConnection.connectionStatus;
		}
		
		switch (connState)
		{
			case WF_SENSOR_CONNECTION_STATUS_IDLE:
			{
				// create the connection params.
				WFConnectionParams* params = nil;
				params = [hardwareConnector.settings connectionParamsForSensorType:sensorType];
				
				sc = [hardwareConnector requestSensorConnection:params];
					
				// set delegate to receive connection status changes.
				sc.delegate = self;
				
				break;
			}
				
			case WF_SENSOR_CONNECTION_STATUS_CONNECTING:
			case WF_SENSOR_CONNECTION_STATUS_CONNECTED:
				// disconnect the sensor.
				[sc disconnect];
				
				break;
				
			case WF_SENSOR_CONNECTION_STATUS_DISCONNECTING:
			case WF_SENSOR_CONNECTION_STATUS_INTERRUPTED:
				// do nothing.
				break;
				
		}
	}
}

#pragma mark -
#pragma mark WFSensorConnectionDelegate Implementation

- (void)sendDataToPeer:(PacketData*)packet
{
	if (gkSession != nil)
	{
		NSMutableData *data = [[NSMutableData alloc] init];
		NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
		[archiver encodeObject:packet forKey:@"PacketData"];
		[archiver finishEncoding];
		
		[gkSession sendData:data toPeers:gkPeers withDataMode:GKSendDataReliable error:nil];
		
		[archiver release];
		[data release];
	}
}

- (void)updateData
{
	if (heartRateConnection != nil && footPodConnection != nil)
	{
		[spinner stopAnimating];
		spinner.hidden = YES;
	}
	
	if (heartRateConnection != nil)
	{
		WFHeartrateData *hrData = [self.heartRateConnection getHeartrateData];
		if (hrData != nil)
		{
			heartMonitor.text = [NSString stringWithFormat:@"%@", [hrData formattedHeartrate:TRUE]];
			
			if (gkSession != nil)
			{
				PacketData *pd = [[PacketData alloc] initWithType:kHeartData];
				[pd addKey:@"bpm" withPayload:[hrData formattedHeartrate:TRUE]];
				
				[self sendDataToPeer:pd];
				
				[pd release];
			}
		}
	}
	
	if (footPodConnection != nil)
	{
		WFFootpodData *fpData = [self.footPodConnection getFootpodData];
		if (fpData != nil)
		{
			pedometer.text = [NSString stringWithFormat:@"%@", [fpData formattedDistance:YES]];
			
			if (gkSession != nil)
			{
				PacketData *pd = [[PacketData alloc] initWithType:kFootData];
				[pd addKey:@"dist" withPayload:[fpData formattedDistance:TRUE]];
				[pd addKey:@"pace" withPayload:[fpData formattedPace:TRUE]];
				[pd addKey:@"cad" withPayload:[fpData formattedCadence:TRUE]];
				[pd addKey:@"spd" withPayload:[fpData formattedSpeed:TRUE]];
				
				[self sendDataToPeer:pd];
				
				[pd release];
			}
		}
	}
}


//--------------------------------------------------------------------------------
- (void)connection:(WFSensorConnection*)connectionInfo stateChanged:(WFSensorConnectionStatus_t)connState
{
    // check for a valid connection.
    if (connectionInfo.isValid)
    {
        // update the stored connection settings.
        [hardwareConnector.settings saveConnectionInfo:connectionInfo];
		
		if ([connectionInfo isKindOfClass:[WFHeartrateConnection class]])
		{
			self.heartRateConnection = (WFHeartrateConnection*)connectionInfo;
		}
		else if ([connectionInfo isKindOfClass:[WFFootpodConnection class]] && footPodConnection == nil)
		{
			self.footPodConnection = (WFFootpodConnection*)connectionInfo;
		}
        
        // update the display.
        [self updateData];
    }
    
    // check for disconnected sensor.
    else if ( connState == WF_SENSOR_CONNECTION_STATUS_IDLE )
    {
        // reset the display.
//        [self resetDisplay];
    }
}

@end
