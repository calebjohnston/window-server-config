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

DisplayMode::DisplayMode(CGDisplayModeRef mode) : mModeRef( mode )
{
	CGDisplayModeRetain(mModeRef);
	
	mType = CGDisplayModeGetTypeID();
	mRefreshRate = CGDisplayModeGetRefreshRate(mModeRef);
	mIoFlags = CGDisplayModeGetIOFlags(mModeRef);
	mIoModeId = CGDisplayModeGetIODisplayModeID(mModeRef);
	mHeight = CGDisplayModeGetHeight(mModeRef);
	mWidth = CGDisplayModeGetWidth(mModeRef);
	mCopyPixelEncoding = CGDisplayModeCopyPixelEncoding(mModeRef);
	mUsableForDesktopGui = CGDisplayModeIsUsableForDesktopGUI(mModeRef);
}

DisplayMode::DisplayMode(const CGDirectDisplayID display)
{
	//CGError err = CGDisplayGetDisplayMode(display, self.modeRef, NULL);
	mModeRef = CGDisplayCopyDisplayMode(display);
	CGDisplayModeRetain(mModeRef);
	
	mType = CGDisplayModeGetTypeID();
	mRefreshRate = CGDisplayModeGetRefreshRate(mModeRef);
	mIoFlags = CGDisplayModeGetIOFlags(mModeRef);
	mIoModeId = CGDisplayModeGetIODisplayModeID(mModeRef);
	mHeight = CGDisplayModeGetHeight(mModeRef);
	mWidth = CGDisplayModeGetWidth(mModeRef);
	mCopyPixelEncoding = CGDisplayModeCopyPixelEncoding(mModeRef);
	mUsableForDesktopGui = CGDisplayModeIsUsableForDesktopGUI(mModeRef);
}

DisplayMode::~DisplayMode()
{
	if (mModeRef) CGDisplayModeRelease(mModeRef);
}

std::string DisplayMode::toString() const
{
	std::stringstream output_str;
	
	output_str << "Device type:\t" << mType << std::endl << "\t";
	output_str << "Refresh Rate:\t" << mRefreshRate << std::endl << "\t";
	output_str << "IO Flags:\t" << mIoFlags << std::endl << "\t";
	output_str << "IO ModeID:\t" << mIoModeId << std::endl << "\t";
	output_str << "Display Size:\t" << (uint32_t)mWidth << " x " << (uint32_t)mHeight << std::endl << "\t";
	output_str << "Desktop GUI:\t" << (mUsableForDesktopGui ? "True" : "False") << std::endl;
	
	return output_str.str();
}

DisplayDevice::DisplayDevice()
:	mDeviceId(0), mDisplayBoundary(CGRectZero), mGammaTableCapacity(0), mIsActive(false), mIsOnline(false),
	mIsAsleep(false), mIsBuiltin(false), mIsAlwaysInMirrorSet(false), mIsInHWMirrorSet(false), mIsMain(false),
	mIsStereo(false), mIsInMirrorSet(false), mUsesOpenGLAcceleration(false), mScreenSize(CGSizeZero),
	mModelNumber(0), mSerialNumber(0), mUnitNumber(0), mVendorNumber(0)
{
	
}

DisplayDevice::DisplayDevice(const CGDirectDisplayID display)
{
	mDeviceId = display;
	
	// query all device information...
	mColorSpace = CGDisplayCopyColorSpace(mDeviceId);
	mGammaTableCapacity = CGDisplayGammaTableCapacity(mDeviceId);
	mDrawingContext = CGDisplayGetDrawingContext(mDeviceId);
	mIsActive = CGDisplayIsActive(mDeviceId);
	mIsAlwaysInMirrorSet = CGDisplayIsAlwaysInMirrorSet(mDeviceId);
	mIsAsleep = CGDisplayIsAsleep(mDeviceId);
	mIsBuiltin = CGDisplayIsBuiltin(mDeviceId);
	mIsInHWMirrorSet = CGDisplayIsInHWMirrorSet(mDeviceId);
	mIsInMirrorSet = CGDisplayIsInMirrorSet(mDeviceId);
	mIsMain = CGDisplayIsMain(mDeviceId);
	mIsOnline = CGDisplayIsOnline(mDeviceId);
	mIsStereo = CGDisplayIsStereo(mDeviceId);
	mUsesOpenGLAcceleration = CGDisplayUsesOpenGLAcceleration(mDeviceId);
	mRotation = CGDisplayRotation(mDeviceId);
	mScreenSize = CGDisplayScreenSize(mDeviceId); // in millimeters
	mModelNumber = CGDisplayModelNumber(mDeviceId);
	mSerialNumber = CGDisplaySerialNumber(mDeviceId);
	mUnitNumber = CGDisplayUnitNumber(mDeviceId);
	mVendorNumber = CGDisplayVendorNumber(mDeviceId);
	mDisplayBoundary = CGDisplayBounds(mDeviceId);
	
	// get the current display mode...
	mCurrentDisplayMode = std::make_shared<DisplayMode>(mDeviceId);
	
	// query all the possible display modes...
	mAllSupportedDisplayModes.clear();
	CFArrayRef displayModes = CGDisplayCopyAllDisplayModes(mDeviceId, NULL);
	CFIndex index, count = CFArrayGetCount(displayModes);
	for (index = 0; index < count; index++) {
		CGDisplayModeRef mode = (CGDisplayModeRef) CFArrayGetValueAtIndex(displayModes, index);
		DisplayModeRef dmode = std::make_shared<DisplayMode>(mode);
		mAllSupportedDisplayModes.push_back(dmode);
	}
}

DisplayDevice::~DisplayDevice()
{
	
}

std::string DisplayDevice::toString() const
{
	std::stringstream output_str;
	
	output_str << displayName() << " - " << mDeviceId << std::endl << "\t";
	output_str << "Model Number:\t" << mModelNumber << std::endl << "\t";
	output_str << "Serial Number:\t" << mSerialNumber << std::endl << "\t";
	output_str << "Unit Number:\t" << mUnitNumber << std::endl << "\t";
	output_str << "Vendor Number:\t" << mVendorNumber << std::endl << "\t";
	output_str << "Screen Size:\t(" << mScreenSize.width << "mm x " << mScreenSize.height << "mm)" << std::endl << "\t";
	output_str << "Rotation:\t" << mRotation << std::endl << "\t";
	output_str << "Is Active:\t" << (mIsActive ? "True" : "False") << std::endl << "\t";
	output_str << "Is Online:\t" << (mIsOnline ? "True" : "False") << std::endl << "\t";
	output_str << "Is Built-in:\t" << (mIsBuiltin ? "True" : "False") << std::endl << "\t";
	output_str << "Is Primary:\t" << (mIsMain ? "True" : "False") << std::endl << "\t";
	output_str << "HW Accelerated:\t" << (mUsesOpenGLAcceleration ? "True" : "False") << std::endl << "\t";
	output_str << "Bounds:\t\t[" << mDisplayBoundary.origin.x << "," << mDisplayBoundary.origin.y << " ";
	output_str << mDisplayBoundary.size.width << "x" << mDisplayBoundary.size.height << "] \t" << std::endl;
	if (mCurrentDisplayMode) {
		output_str << "      *\tCurrent Display Mode" << std::endl << "\t";
		output_str << mCurrentDisplayMode->toString();
	}
	
	return output_str.str();
}

std::string DisplayDevice::displayName() const
{
	NSString *displayProductName = nil;

	// Get a CFDictionary with a key for the preferred name of the display.
	NSDictionary *displayInfo = (NSDictionary *)IODisplayCreateInfoDictionary(CGDisplayIOServicePort(mDeviceId), kIODisplayOnlyPreferredName);
	// Retrieve the display product name.
	NSDictionary *localizedNames = [displayInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];

	// Use the first name.
	if ([localizedNames count] > 0) {
		displayProductName = [[localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]] retain];
	}

	[displayInfo release];
	return [[displayProductName autorelease] UTF8String];
}

