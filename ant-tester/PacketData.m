//
//  PacketData.m
//  ant-tester
//
//  Created by Jeremy Jessup on 12/11/11.
//  Copyright (c) 2011 The Active Network Inc. All rights reserved.
//

#import "PacketData.h"

@interface PacketData ()
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, retain) NSMutableArray *keyArray;
@property (nonatomic, retain) NSMutableArray *payloadArray;
@end

@implementation PacketData
@synthesize version;
@synthesize packetType;
@synthesize keyArray;
@synthesize payloadArray;

- (id)initWithType:(PacketDataType)pType
{
	if (self = [super init])
	{
		version	= 1;
		
		packetType	= pType;
		
		keyArray	= [[NSMutableArray alloc] init];
		payloadArray= [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[keyArray release];
	[payloadArray release];
	
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self.version		= [coder decodeIntForKey:@"version"];
	self.packetType		= [coder decodeIntForKey:@"packetType"];
	self.keyArray		= [coder decodeObjectForKey:@"keyArray"];
	self.payloadArray	= [coder decodeObjectForKey:@"payloadArray"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt:version forKey:@"version"];
	[coder encodeInt:packetType forKey:@"packetType"];
	[coder encodeObject:keyArray forKey:@"keyArray"];
	[coder encodeObject:payloadArray forKey:@"payloadArray"];
}

- (void)addKey:(NSString*)key withPayload:(id)obj
{
	if (key != nil && obj != nil)
	{
		[keyArray addObject:key];
		[payloadArray addObject:obj];
	}
}

- (id)getObjectForKey:(NSString *)key
{
	for (int i=0; i<[keyArray count]; ++i)
	{
		if ([[keyArray objectAtIndex:i] caseInsensitiveCompare:key] == NSOrderedSame)
		{
			return [payloadArray objectAtIndex:i];
		}
	}
	
	return nil;
}

@end
