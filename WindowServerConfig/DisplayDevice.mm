//
//  DisplayDevice.m
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/20/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/graphics/IOGraphicsLib.h>
#import <IOKit/graphics/IOGraphicsTypes.h>
#import <IOKit/graphics/IOGraphicsInterface.h>

#import "DisplayDevice.h"

#include <sstream>

DisplayMode::DisplayMode(CGDisplayModeRef mode) : modeRef( mode )
{
	CGDisplayModeRetain(modeRef);
	
	type = CGDisplayModeGetTypeID();
	refreshRate = CGDisplayModeGetRefreshRate(modeRef);
	ioFlags = CGDisplayModeGetIOFlags(modeRef);
	ioModeId = CGDisplayModeGetIODisplayModeID(modeRef);
	height = CGDisplayModeGetHeight(modeRef);
	width = CGDisplayModeGetWidth(modeRef);
	copyPixelEncoding = CGDisplayModeCopyPixelEncoding(modeRef);
	usableForDesktopGui = CGDisplayModeIsUsableForDesktopGUI(modeRef);
}

DisplayMode::DisplayMode(const CGDirectDisplayID display)
{
	//CGError err = CGDisplayGetDisplayMode(display, self.modeRef, NULL);
	modeRef = CGDisplayCopyDisplayMode(display);
	CGDisplayModeRetain(modeRef);
	
	type = CGDisplayModeGetTypeID();
	refreshRate = CGDisplayModeGetRefreshRate(modeRef);
	ioFlags = CGDisplayModeGetIOFlags(modeRef);
	ioModeId = CGDisplayModeGetIODisplayModeID(modeRef);
	height = CGDisplayModeGetHeight(modeRef);
	width = CGDisplayModeGetWidth(modeRef);
	copyPixelEncoding = CGDisplayModeCopyPixelEncoding(modeRef);
	usableForDesktopGui = CGDisplayModeIsUsableForDesktopGUI(modeRef);
}

DisplayMode::~DisplayMode()
{
	CGDisplayModeRelease(modeRef);
}

std::string DisplayMode::toString() const
{
	/*
	NSString* fmt = @"    - Display Mode\n\t %@ %li\n\t %@ %.1f\n\t %@ %i\n\t %@ %i\n\t %@ (%i x %i)\n\t %@ %@\n";
	NSString* output = [NSString stringWithFormat:fmt,
						@"Device type:\t", type,
						@"Refresh Rate:\t", refreshRate,
						@"IO Flags:\t", ioFlags,
						@"IO ModeID:\t", ioModeId,
						@"Display Size:\t", (uint32_t)width, (uint32_t)height,
						@"Desktop GUI:\t", (usableForDesktopGui ? @"True" : @"False")];
	
	return [output UTF8String];
	*/
	
	std::stringstream output_str;
	output_str << "    - Display Mode" << std::endl;
	output_str << "Device type:\t" << type << std::endl << "\t";
	output_str << "Refresh Rate:\t" << refreshRate << std::endl << "\t";
	output_str << "IO Flags" << ioFlags << std::endl << "\t";
	output_str << "IO ModeID:\t" << ioModeId << std::endl << "\t";
	output_str << "Display Size:\t" << (uint32_t)width << " x " << (uint32_t)height << std::endl << "\t";
	output_str << "Desktop GUI:\t" << (usableForDesktopGui ? "True" : "False") << std::endl;
	
	return output_str.str();
}

DisplayDevice::DisplayDevice(const CGDirectDisplayID display)
{
	deviceId = display;
	colorSpace = CGDisplayCopyColorSpace(deviceId);
	gammaTableCapacity = CGDisplayGammaTableCapacity(deviceId);
	drawingContext = CGDisplayGetDrawingContext(deviceId);
	isActive = CGDisplayIsActive(deviceId);
	isAlwaysInMirrorSet = CGDisplayIsAlwaysInMirrorSet(deviceId);
	isAsleep = CGDisplayIsAsleep(deviceId);
	isBuiltin = CGDisplayIsBuiltin(deviceId);
	isInHWMirrorSet = CGDisplayIsInHWMirrorSet(deviceId);
	isInMirrorSet = CGDisplayIsInMirrorSet(deviceId);
	isMain = CGDisplayIsMain(deviceId);
	isOnline = CGDisplayIsOnline(deviceId);
	isStereo = CGDisplayIsStereo(deviceId);
	usesOpenGLAcceleration = CGDisplayUsesOpenGLAcceleration(deviceId);
	rotation = CGDisplayRotation(deviceId);
	screenSize = CGDisplayScreenSize(deviceId); // in millimeters
	modelNumber = CGDisplayModelNumber(deviceId);
	serialNumber = CGDisplaySerialNumber(deviceId);
	unitNumber = CGDisplayUnitNumber(deviceId);
	vendorNumber = CGDisplayVendorNumber(deviceId);
	displayBoundary = CGDisplayBounds(deviceId);
	
	displayMode = std::make_shared<DisplayMode>(deviceId);
}

DisplayDevice::~DisplayDevice()
{
	
}

std::string DisplayDevice::toString() const
{
/*
	NSString* fmt = @"%@ - %i\n\t %@ %i\n\t %@ %i\n\t %@ %i\n\t %@ %i\n\t %@ (%.0fmm x %.0fmm)\n\t %@ %.1f\n\t %@ %@\n\t %@ %@\n\t %@ %@\n\t %@ %@\n\t %@ %@\n\t %@ [%.0f,%.0f %.0fx%.0f]\n";
	NSString* displayName = [self displayNameFromDisplayId:deviceId];
	NSString* output = [NSString stringWithFormat:fmt,
						displayName, deviceId,
						@"Model Number:\t", modelNumber,
						@"Serial Number:\t", serialNumber,
						@"Unit Number:\t", unitNumber,
						@"Vendor Number:\t", vendorNumber,
						@"Screen Size:\t", screenSize.width, screenSize.height,
						@"Rotation:\t", rotation,
						@"Is Active:\t", (isActive ? @"True" : @"False"),
						@"Is Online:\t", (isOnline ? @"True" : @"False"),
						@"Is Built-in:\t", (isBuiltin ? @"True" : @"False"),
						@"Is Primary:\t", (isMain ? @"True" : @"False"),
						@"HW Accelerated:", (usesOpenGLAcceleration ? @"True" : @"False"),
						@"Bounds:\t", displayBoundary.origin.x, displayBoundary.origin.y, displayBoundary.size.width, displayBoundary.size.height ];
//	output = [output stringByAppendingString:[displayMode toNSString]];
 
	return [output UTF8String];
*/
	
	
	std::stringstream output_str;
	output_str << displayName() << " - " << deviceId << std::endl << "\t";
	output_str << "Model Number:\t" << modelNumber << std::endl << "\t";
	output_str << "Serial Number:\t" << serialNumber << std::endl << "\t";
	output_str << "Unit Number:\t" << unitNumber << std::endl << "\t";
	output_str << "Vendor Number:\t" << vendorNumber << std::endl << "\t";
	output_str << "Screen Size:\t (" << screenSize.width << "mm x " << screenSize.height << "mm)" << std::endl << "\t";
	output_str << "Rotation:\t" << rotation << std::endl << "\t";
	output_str << "Is Active:\t" << (isActive ? "True" : "False") << std::endl << "\t";
	output_str << "Is Online:\t" << (isOnline ? "True" : "False") << std::endl << "\t";
	output_str << "Is Built-in:\t" << (isBuiltin ? "True" : "False") << std::endl << "\t";
	output_str << "Is Primary:\t" << (isMain ? "True" : "False") << std::endl << "\t";
	output_str << "HW Accelerated:\t" << (usesOpenGLAcceleration ? "True" : "False") << std::endl << "\t";
	output_str << "Bounds:\t [" << displayBoundary.origin.x << "," << displayBoundary.origin.y << " ";
	output_str << displayBoundary.size.width << "x" << displayBoundary.size.height << std::endl << "] \t";
	output_str << (displayMode ? displayMode->toString() : "");
	
	return output_str.str();
	
	
}

std::string DisplayDevice::displayName() const
{
	NSString *displayProductName = nil;

	// Get a CFDictionary with a key for the preferred name of the display.
	NSDictionary *displayInfo = (NSDictionary *)IODisplayCreateInfoDictionary(CGDisplayIOServicePort(deviceId), kIODisplayOnlyPreferredName);
	// Retrieve the display product name.
	NSDictionary *localizedNames = [displayInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];

	// Use the first name.
	if ([localizedNames count] > 0) {
		displayProductName = [[localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]] retain];
	}

	[displayInfo release];
	return [[displayProductName autorelease] UTF8String];
}

