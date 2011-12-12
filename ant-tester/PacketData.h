//
//  PacketData.h
//  ant-tester
//
//  Created by Jeremy Jessup on 12/11/11.
//  Copyright (c) 2011 The Active Network Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	kHeartData,
	kFootData
} PacketDataType;

@interface PacketData : NSObject
	<NSCoding>
{
	NSInteger		version;
	PacketDataType	packetType;
	
	NSMutableArray *keyArray;
	NSMutableArray *payloadArray;
}

@property (nonatomic, assign) PacketDataType packetType;

- (id)initWithType:(PacketDataType)pType;

- (void)addKey:(NSString*)key withPayload:(id)obj;
- (id)getObjectForKey:(NSString*)key;


@end
