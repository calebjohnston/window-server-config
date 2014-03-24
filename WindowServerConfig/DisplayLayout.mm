//
//  DisplayConfiguration.cpp
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/21/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#ifdef __OBJC__
	#import <ApplicationServices/ApplicationServices.h>
	#import <Foundation/Foundation.h>
	#import <IOKit/IOKitLib.h>
	#import "DisplayDevice.h"
#endif

#include "DisplayLayout.h"

DisplayLayout::DisplayLayout() : mOrientation(NORMAL), mPrimary(UPPER_LEFT), mColumns(1), mRows(1), mResWidth(0), mResHeight(0)
{
}

DisplayLayout::~DisplayLayout()
{
	if (nullptr != mConfigRef) {
		CGError result = CGCancelDisplayConfiguration(mConfigRef);
		//if (kCGErrorSuccess != err) {
		//	std::cout << "Configuration error : " << err << std::endl;
		//}
	}
}

bool DisplayLayout::applyLayoutChanges()
{
	// begin configuration
	CGError err = CGBeginDisplayConfiguration(&mConfigRef);
	if (kCGErrorSuccess != err) {
		std::cout << "Could not begin reconfiguration: " << err << std::endl;
		return false;
	}
	
	// perform device query
	mQuery = std::make_shared<DisplayQuery>();
	CGError capture_err = CGCaptureAllDisplays();
	if (kCGErrorSuccess != capture_err) {
		std::cout << "Could not capture displays: " << capture_err << std::endl;
		return false;
	}
	
	// verify that the right display mode exist for all displays
	bool isResolutionSupported = true;
	for (auto device_iter = mQuery->displays().begin(); device_iter != mQuery->displays().end(); device_iter++)
	{
		const DisplayDeviceRef& device = *device_iter;
		uint32_t resolution_x = device->getCurrentDisplayMode()->getWidth();
		uint32_t resolution_y = device->getCurrentDisplayMode()->getHeight();
		if (0 == mResWidth || 0 == mResHeight) {
			mResWidth = resolution_x;
			mResHeight = resolution_y;
		}
		else if (desiredResolutionWidth() != resolution_x || desiredResolutionHeight() != resolution_y)
		{
			isResolutionSupported = false;
			
			// if the current display mode is not set to the desired display mode, then we will change it...
			const std::vector<DisplayModeRef>& displayModes = device->getAllDisplayModes();
			for (auto mode_iter = displayModes.begin(); mode_iter != displayModes.end(); mode_iter++) {
				const DisplayModeRef& mode = *mode_iter;
				resolution_x = mode->getWidth();
				resolution_y = mode->getHeight();
				if (desiredResolutionWidth() == resolution_x && desiredResolutionHeight() == resolution_y && mode->usableForDesktopGui()) {
					CGError profile_err = CGConfigureDisplayWithDisplayMode(mConfigRef, device->getDeviceId(), mode->getNativePtr(), NULL);
					if (kCGErrorSuccess != profile_err) {
						std::cerr << "Could not update device profile for device ID: ";
						std::cerr << device->getDeviceId() << " due to Error: " << profile_err << std::endl;
						isResolutionSupported = false;
					}
					else {
						isResolutionSupported = true;
						break;
					}
				}
			}
			
			if (!isResolutionSupported) {
				std::cerr << "Desired resolution (" << mResWidth << "x" << mResHeight << ") not supported." << std::endl;
				return false;
			}
		}
	}
	
	// this does not work...
	//err = CGConfigureDisplayWithDisplayMode(mConfigRef, [mQuery->displays().back() getDeviceId], [mQuery->displays().front() getMode], NULL);
	// this works...
	//err = CGConfigureDisplayOrigin(mConfigRef, 69678080, 1920, 0);
	
	// reposition all displays
	CGError result;
	size_t count = mQuery->displays().size();
	size_t index = 0;
	for (uint8_t y = 0; y < desiredRows(); y++) {
		for (uint8_t x = 0; x < desiredColumns(); x++, index++) {
			if (x * y >= count || index >= count || !mQuery->displays().at(index)) break;
			
			result = CGConfigureDisplayOrigin(mConfigRef, mQuery->displays().at(index)->getDeviceId(), x * mResWidth, y * mResHeight);
			if (kCGErrorSuccess != result) {
				std::cerr << "Could not update display position! Error: " << result << " for device id: ";
				std::cerr << mQuery->displays().at(index)->getDeviceId() << std::endl;
				return false;
			}
		}
	}
	
	switch (mPrimary) {
		case UPPER_LEFT:
//			mQuery->displays().at(index)
			
			break;
			
		case UPPER_RIGHT:
			break;
			
		case LOWER_LEFT:
			break;
			
		case LOWER_RIGHT:
			break;
	}
	
	result = CGCompleteDisplayConfiguration(mConfigRef, kCGConfigureForSession);
	
	bool success = (kCGErrorSuccess == result);
	
	if (success) {
		// rotate 90 degrees...
		//		CGDirectDisplayID display = CGMainDisplayID();
		//		io_service_t service = CGDisplayIOServicePort(display);
		//		IOOptionBits options = (0x00000400 | (kIOScaleRotate90)  << 16);
		//		IOServiceRequestProbe(service, options);
		
	}
	
	if (!success) {
		std::cerr << "Configure Completion error : " << result << std::endl;
	}
	
	
	return success;
}

