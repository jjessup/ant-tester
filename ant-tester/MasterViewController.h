//
//  MasterViewController.h
//  ant-tester
//
//  Created by Jeremy Jessup on 12/11/11.
//  Copyright (c) 2011 The Active Network Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WFConnector/WFConnector.h>
#import <GameKit/GameKit.h>

@class DetailViewController;

@interface MasterViewController : UIViewController
	<WFSensorConnectionDelegate, GKSessionDelegate, GKPeerPickerControllerDelegate>
{
	IBOutlet UIButton *detectAntDevices;
	IBOutlet UILabel *heartMonitor;
	IBOutlet UILabel *pedometer;
	
	IBOutlet UIButton *connectButton;
	IBOutlet UILabel *peerHeartRate;
	IBOutlet UILabel *peerFootPod;
	
	IBOutlet UIButton *trackButton;
	
	IBOutlet UIActivityIndicatorView *spinner;
	
	WFHardwareConnector		*hardwareConnector;
	WFHeartrateConnection	*heartRateConnection;
	WFFootpodConnection		*footPodConnection;
	
	GKSession				*gkSession;
	GKPeerPickerController	*gkPickerCtrl;
	NSMutableArray			*gkPeers;
}

@property (nonatomic, retain) UIButton *detectAntDevices;
@property (nonatomic, retain) UILabel *heartMonitor;
@property (nonatomic, retain) UILabel *pedometer;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

@property (nonatomic, assign) WFHeartrateConnection *heartRateConnection;
@property (nonatomic, assign) WFFootpodConnection *footPodConnection;

@property (nonatomic, retain) GKSession *gkSession;

- (IBAction)detectAntDevicesButtonPressed:(id)sender;
- (IBAction)connectButtonPressed:(id)sender;

- (IBAction)trackButtonPressed:(id)sender;

@end
