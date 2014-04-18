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

DisplayLayout::DisplayLayout()
 :	mOrientation(NORMAL), mPrimary(UPPER_LEFT), mColumns(1), mRows(1), mResWidth(0), mResHeight(0), mPersistence(PERMANENT)
{
}

DisplayLayout::~DisplayLayout()
{
	if (nullptr != mConfigRef) {
		CGCancelDisplayConfiguration(mConfigRef);
	}
}

void DisplayLayout::setDesiredFrameForDisplay(const uint32_t device_id, const Frame frame)
{
	std::unordered_map<uint32_t, Frame>::const_iterator iter = mDeviceFrames.find(device_id);
	if (iter == mDeviceFrames.end()) {
		mDeviceFrames.insert(std::make_pair(device_id, frame));
	}
	else {
		mDeviceFrames.emplace(device_id, frame);
	}
}

DisplayLayout::Frame DisplayLayout::getDesiredFrameForDisplay(const uint32_t device_id)
{
	Frame frame = {0,0,0,0};
	std::unordered_map<uint32_t, Frame>::const_iterator iter = mDeviceFrames.find(device_id);
	if (iter == mDeviceFrames.end()) {
		return frame;
	}
	else {
		return iter->second;
	}
}

bool DisplayLayout::applyLayoutChanges()
{
	// begin configuration
	CGError err = CGBeginDisplayConfiguration(&mConfigRef);
	if (kCGErrorSuccess != err) {
		std::cout << "Error! Could not begin reconfiguration: " << err << std::endl;
		return false;
	}
	
	// perform device query
	mQuery = std::make_shared<DisplayQuery>();
	CGError capture_err = CGCaptureAllDisplaysWithOptions(kCGCaptureNoFill);
	if (kCGErrorSuccess != capture_err) {
		std::cout << "Error! Could not capture displays: " << capture_err << std::endl;
		return false;
	}
	
	// verify that the right display mode exist for all displays
	bool isResolutionSupported = true;
	
	// determine if we need to check for individually submitted display data to apply
	const bool configureAllDisplaysIndividually = !mDeviceFrames.empty();
	
	// iterate through displays and apply resolution settings
	for (const DisplayDeviceRef device : mQuery->displays())
	{
		uint32_t resolution_x = device->getCurrentDisplayMode()->getWidth();
		uint32_t resolution_y = device->getCurrentDisplayMode()->getHeight();
		
		// if we have display frames defined for each display, then we will use that...
		if (configureAllDisplaysIndividually) {
			auto iter = mDeviceFrames.find(device->getDeviceId());
			if (iter != mDeviceFrames.end()) {
				mResWidth = iter->second.width;
				mResHeight = iter->second.height;
			}
		}
		
		// if the resolution is set to something impossible then we don't assign it
		// but we use the default resolution for the rest of the layout...
		if (0 == mResWidth || 0 == mResHeight) {
			mResWidth = resolution_x;
			mResHeight = resolution_y;
		}
		// if the chosen resolution does not match the existing resolution, then we must pick the matching display mode and apply it.
		else if (desiredResolutionWidth() != resolution_x || desiredResolutionHeight() != resolution_y)
		{
			isResolutionSupported = false;
			
			// if the current display mode is not set to the desired display mode, then we will change it...
			const std::vector<DisplayModeRef>& displayModes = device->getAllDisplayModes();
			//for (auto mode_iter = displayModes.begin(); mode_iter != displayModes.end(); mode_iter++) {
			for (const DisplayModeRef mode : displayModes) {
				//const DisplayModeRef& mode = *mode_iter;
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
			
			// maybe should not do this ...
			if (!isResolutionSupported) {
				std::cerr << "Desired resolution (" << mResWidth << "x" << mResHeight << ") not supported on device id: ";
				std::cerr << device->getDeviceId() << ". Attempting best fit..." << std::endl;
			}
		}
	}
	
	// define error type for all future operations...
	CGError result;
	
	// set all displays to individually assigned origins if desired
	if (configureAllDisplaysIndividually) {
		for (const DisplayDeviceRef device : mQuery->displays()) {
			CGDirectDisplayID device_id = device->getDeviceId();
			auto iter = mDeviceFrames.find(device_id);
			if (iter != mDeviceFrames.end()) {
				result = CGConfigureDisplayOrigin(mConfigRef, device_id, iter->second.position_x, iter->second.position_y);
				if (kCGErrorSuccess != result) {
					std::cerr << "Error! Could not update display position for device id: " << device_id << std::endl;
					return false;
				}
			}
			else {
				std::cerr << "Error! Could not locate display for device id: " << device_id << std::endl;
				return false;
			}
		}
	}
	// OR reposition all displays
	else {
		size_t count = mQuery->displays().size();
		size_t index = 0;
		for (uint8_t y = 0; y < desiredRows(); y++) {
			for (uint8_t x = 0; x < desiredColumns(); x++, index++) {
				if (x * y >= count || index >= count || !mQuery->displays().at(index)) break;
				
				result = CGConfigureDisplayOrigin(mConfigRef, mQuery->displays().at(index)->getDeviceId(), x * mResWidth, y * mResHeight);
				if (kCGErrorSuccess != result) {
					std::cerr << "Error! Could not update display position for device id: ";
					std::cerr << mQuery->displays().at(index)->getDeviceId() << std::endl;
					return false;
				}
			}
		}
	}
	
	// assign the proper setting context...
	CGConfigureOption option;
	switch (mPersistence) {
		case APPLICATION:
			option = kCGConfigureForAppOnly;
			break;
			
		case SESSION:
			option = kCGConfigureForSession;
			break;
			
		case PERMANENT:
			option = kCGConfigurePermanently;
			break;
	}
	result = CGCompleteDisplayConfiguration(mConfigRef, option);
	bool success = (kCGErrorSuccess == result);
	if (success) {
		// Perform rotation...
		IOOptionBits options;
		switch (mOrientation) {
			case NORMAL:
				options = (0x00000400 | (kIOScaleRotate0)  << 16);
				break;

			case ROTATE_90:
				options = (0x00000400 | (kIOScaleRotate90)  << 16);
				break;

			case ROTATE_180:
				options = (0x00000400 | (kIOScaleRotate180)  << 16);
				break;

			case ROTATE_270:
				options = (0x00000400 | (kIOScaleRotate270)  << 16);
				break;
		}
		for (const DisplayDeviceRef device : mQuery->displays()) {
			CGDirectDisplayID display = device->getDeviceId();
			io_service_t service = CGDisplayIOServicePort(display);
			IOServiceRequestProbe(service, options);
		}
		
		/*
		io_service_t service = CGDisplayIOServicePort(mQuery->displays().front()->getDeviceId());
		task_port_t owningTask;
		unsigned int type;
		io_connect_t connect;
		kern_return_t kern_id = IOFramebufferOpen( service, owningTask, type, &connect );
		IOPixelAperture aperture;
		IOFramebufferInformation info;
		kern_return_t IOFBGetFramebufferInformationForAperture( connect, aperture, &info );
		 */
		
		mConfigRef = nullptr;
	}
	else {
		std::cerr << "Error! Could not apply configuration: " << result << std::endl;
	}
	
	CGReleaseAllDisplays();
	
	return success;
}

