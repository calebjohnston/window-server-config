//
//  DisplayQuery.m
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/20/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#ifdef __OBJC__
	#import <ApplicationServices/ApplicationServices.h>
	#import <Foundation/Foundation.h>
	#import <CoreGraphics/CoreGraphics.h>
	#import <IOKit/IOKitLib.h>
	#import "DisplayDevice.h"
#endif

#include <iostream>

#include "DisplayQuery.h"

DisplayQuery::DisplayQuery()
{
	uint32_t maximum = 12;
	CGDirectDisplayID* displays = (CGDirectDisplayID*) calloc(maximum, sizeof(uint32_t));
	uint32_t total;
	CGError err = CGGetOnlineDisplayList(maximum, displays, &total);
	
	if (kCGErrorSuccess == err) {
		for (size_t index = 0; index < total; index++) {
			DisplayDevice* device = [[DisplayDevice alloc] initWithDisplay:displays[index]];
			mDisplays.push_back(device);
		}
	}
}

DisplayQuery::~DisplayQuery()
{
	
	
	
//	CFArrayRef displayModes = CGDisplayCopyAllDisplayModes([mQuery->displays().front() getDeviceId], NULL);
//	CFIndex index, count = CFArrayGetCount(displayModes);
//	for (index = 0; index < count; index++) {
//		CGDisplayModeRef mode = (CGDisplayModeRef) CFArrayGetValueAtIndex(displayModes, index);
//		DisplayMode* dmode = [[DisplayMode alloc] initWithDisplayMode:mode];
//		std::cout << [[dmode toNSString] UTF8String] << std::endl;
//	}
	
}

std::string DisplayQuery::toString()
{
	NSString* output = [[NSString alloc] init];
	
	for (DisplayDevice* device : mDisplays) {
		NSString* dspl = [device toNSString];
		output = [output stringByAppendingString:dspl];
		output = [output stringByAppendingString:@"\n"];
	}
	
	return std::string([output UTF8String]);
}

