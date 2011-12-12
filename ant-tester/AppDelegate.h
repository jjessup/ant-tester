//
//  AppDelegate.h
//  ant-tester
//
//  Created by Jeremy Jessup on 12/11/11.
//  Copyright (c) 2011 The Active Network Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WFConnector/WFConnector.h>


// these could be placed in the pch file to "globalize"
#define WF_NOTIFICATION_HW_CONNECTED           @"WFNotificationHWConnected"
#define WF_NOTIFICATION_HW_DISCONNECTED        @"WFNotificationHWDisconnected"
#define WF_NOTIFICATION_SENSOR_CONNECTED       @"WFNotificationSensorConnected"
#define WF_NOTIFICATION_SENSOR_DISCONNECTED    @"WFNotificationSensorDisconnected"
#define WF_NOTIFICATION_SENSOR_HAS_DATA        @"WFNotificationSensorHasData"

@interface AppDelegate : UIResponder 
	<UIApplicationDelegate, WFHardwareConnectorDelegate>
{
	WFHardwareConnector *wfHardwareConnector;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

@end
