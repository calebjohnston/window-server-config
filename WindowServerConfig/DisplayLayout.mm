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
		//err = CGConfigureDisplayOrigin(mConfigRef, 69678080, 1920, 0);
		err = CGCancelDisplayConfiguration(mConfigRef);
		if (kCGErrorSuccess != err) {
			std::cout << "Configuration error : " << err << std::endl;
		}
	}
}

DisplayLayout::~DisplayLayout()
{
	CGError err = CGCompleteDisplayConfiguration(mConfigRef, kCGConfigureForSession);
	
	if (kCGErrorSuccess == err) {
		// rotate 90 degrees...
//		CGDirectDisplayID display = CGMainDisplayID();
//		io_service_t service = CGDisplayIOServicePort(display);
//		IOOptionBits options = (0x00000400 | (kIOScaleRotate90)  << 16);
//		IOServiceRequestProbe(service, options);
		
	}
	
	if (kCGErrorSuccess != err) {
		std::cout << "Configure Completion error : " << err << std::endl;
	}
}

