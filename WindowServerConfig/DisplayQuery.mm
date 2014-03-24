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
#endif

#include <iostream>

#include "DisplayDevice.h"
#include "DisplayQuery.h"

DisplayQuery::DisplayQuery()
{
	uint32_t maximum = 12;
	CGDirectDisplayID* displays = (CGDirectDisplayID*) calloc(maximum, sizeof(uint32_t));
	uint32_t total;
	CGError err = CGGetOnlineDisplayList(maximum, displays, &total);
	
	if (kCGErrorSuccess == err) {
		for (size_t index = 0; index < total; index++) {
			DisplayDeviceRef device = std::make_shared<DisplayDevice>(displays[index]);
			mDisplays.push_back(device);
		}
	}
}

DisplayQuery::~DisplayQuery()
{
	mDisplays.clear();
}

const DisplayDeviceRef DisplayQuery::getDisplay(const int32_t deviceId) const
{
	for (const DisplayDeviceRef device : mDisplays) {
		if (device->getDeviceId() == deviceId) {
			return device;
		}
	}
	
	return DisplayDeviceRef(0);
}