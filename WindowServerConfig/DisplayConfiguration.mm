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
	#import <CoreGraphics/CoreGraphics.h>
	#import <CoreGraphics/CGDisplayConfiguration.h>
	#import "DisplayDevice.h"
#endif

#include "DisplayConfiguration.h"

CGDisplayConfigRef mConfigRef;

DisplayConfiguration::DisplayConfiguration()
{
	CGError err = CGBeginDisplayConfiguration(&mConfigRef);
	if (kCGErrorSuccess == err) {
		mQuery = std::make_shared<DisplayQuery>();
		CGError capture_err = CGCaptureAllDisplays();
		if (kCGErrorSuccess != capture_err) {
			std::cout << "Could not capture displays: " << capture_err << std::endl;
		}
		
		// this does not work...
		//err = CGConfigureDisplayWithDisplayMode(mConfigRef, [mQuery->displays().back() getDeviceId], [mQuery->displays().front() getMode], NULL);
		
		// this works...
		err = CGConfigureDisplayOrigin(mConfigRef, 69678080, 1920, 0);
		if (kCGErrorSuccess != err) {
			std::cout << "Configuration error : " << err << std::endl;
		}
	}
}

DisplayConfiguration::~DisplayConfiguration()
{
	CGError err = CGCompleteDisplayConfiguration(mConfigRef, kCGConfigureForSession);
	
	if (kCGErrorSuccess == err) {
		std::cout << "Configure Completion error : " << err << std::endl;
	}
}

