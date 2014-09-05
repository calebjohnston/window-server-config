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
#include "DisplayDevice.h"


// CoreGraphics DisplayMode struct used in private APIs
typedef struct
{
    uint32_t modeNumber;
    uint32_t flags;
    uint32_t width;
    uint32_t height;
    uint32_t depth;
    uint8_t unknown[170];
    uint16_t freq;
    uint8_t more_unknown[16];
    float density;
    
//    void dump()
//    {
//        ofLog() << "modeNumber = " << modeNumber;
//        ofLog() << "flags = " << flags;
//        ofLog() << "width = " << width;
//        ofLog() << "height = " << height;
//        ofLog() << "depth = " << depth;
//        ofLog() << "freq = " << freq;
//        ofLog() << "density = " << density;
//    }
}
CGSDisplayMode;

extern "C"
{
    void CGSGetCurrentDisplayMode(CGDirectDisplayID display, int *modeNum);
    void CGSConfigureDisplayMode(CGDisplayConfigRef config, CGDirectDisplayID display, int modeNum);
    void CGSGetNumberOfDisplayModes(CGDirectDisplayID display, int *nModes);
    void CGSGetDisplayModeDescriptionOfLength(CGDirectDisplayID display, int idx, CGSDisplayMode *mode, int length);
};

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

bool DisplayLayout::applyChanges() {
    std::cout << "\n\n\n\n\n---------------------- applyChanges ----------------------" << std::endl;
    
    CGError err;
    
    // Get displays
    
    uint32_t displayCount;
    err = CGGetActiveDisplayList(0, 0, &displayCount);
    if(err != kCGErrorSuccess) return false;
    
    // Allocate storage for the next CGGetActiveDisplayList call

    CGDirectDisplayID* displayIDs = (CGDirectDisplayID*) malloc(displayCount * sizeof(CGDirectDisplayID));
    
    err = CGGetActiveDisplayList(displayCount, displayIDs, &displayCount);
    if(err != kCGErrorSuccess) {
        NSLog(@"CGGetActiveDisplayList error: %d\n", err);
        return false;
    }
    
    NSLog(@"\tdisplayCount: %d\n\n\n", displayCount);
    
    
    int i = 0;
    do {
//    for (int i=0; i<displayCount; i++) {
    
        NSLog(@"\tdisplayID: %d\n", displayIDs[i]);
        
        double rotation = CGDisplayRotation(displayIDs[i]);
        NSLog(@"current rotation: %f\n", rotation);
        NSLog(@"target  rotation: %d\n", mOrientation);
        
        io_service_t service = CGDisplayIOServicePort(displayIDs[i]);

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
        
        err = IOServiceRequestProbe(service, options);
        if(err != kCGErrorSuccess) {
            NSLog(@"IOServiceRequestProbe -- DisplayID: %d\terror: %d\n\n\n", displayIDs[i], err);
            continue;
        }
        
        // Need to pause for a bit for the CG system to catch up
        sleep(4);
        
        NSLog(@"IOServiceRequestProbe ------- %d \n\n\n", service);

        if (0 == mResWidth || 0 == mResHeight) {
            continue;
            CGDisplayModeRef currMode = CGDisplayCopyDisplayMode(displayIDs[i]);
            mResWidth = CGDisplayModeGetWidth(currMode);
			mResHeight = CGDisplayModeGetHeight(currMode);
		}

        CGDisplayConfigRef config;
        err = CGBeginDisplayConfiguration(&config);
        if(err != kCGErrorSuccess) {
            NSLog(@"CGBeginDisplayConfiguration error: %d\n", err);
            continue;
        }
        
        NSLog(@"CGBeginDisplayConfiguration -------\n");
        
        rotation = CGDisplayRotation(displayIDs[i]);
        NSLog(@"current rotation: %f\n", rotation);

        int numberOfDisplayModes;
        CGSGetNumberOfDisplayModes(displayIDs[i], &numberOfDisplayModes);
        
        NSLog(@"CGSGetNumberOfDisplayModes: %d\n", numberOfDisplayModes);
        
        
        
        
        CFArrayRef displayModes = CGDisplayCopyAllDisplayModes(displayIDs[i], 0);
        if(!displayModes) {
            NSLog(@"CGDisplayCopyAllDisplayModes not found\n");
            continue;
        }
        
        NSLog(@"CGDisplayCopyAllDisplayModes -------\n");
        
        NSLog(@"desired resolution: %d x %d\n", desiredResolutionWidth(), desiredResolutionHeight());
        
        CGDisplayModeRef targetMode = nil;
            for(int j=0, n=CFArrayGetCount(displayModes); j<n; j++) {
                
                CGDisplayModeRef mode = (CGDisplayModeRef) CFArrayGetValueAtIndex(displayModes, j);
                size_t width = CGDisplayModeGetWidth(mode);
                size_t height = CGDisplayModeGetHeight(mode);
                NSLog(@"mode width*height: %d x %d\n", width, height);
            
//            if(mOrientation == ROTATE_90 || mOrientation == ROTATE_270) {
//                if(desiredResolutionWidth() == height && desiredResolutionHeight() == width) {
//                    targetMode = mode;
//                    break;
//                }
//            } else {
                if(desiredResolutionWidth() == width && desiredResolutionHeight() == height) {
                    targetMode = mode;
                    break;
//                }
                }
            }
            CFRelease(displayModes);
        
        if(targetMode == nil) {
            NSLog(@"targetMode not found\n\n\n");
            continue;
        }
        
        err = CGConfigureDisplayWithDisplayMode(config, displayIDs[i], targetMode, 0);
        if(err != kCGErrorSuccess) {
            NSLog(@"CGConfigureDisplayWithDisplayMode error: %d\n", err);
            continue;
        }
        
        NSLog(@"CGConfigureDisplayWithDisplayMode -------\n");
        
        err = CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
        if(err != kCGErrorSuccess) {
            NSLog(@"CGCompleteDisplayConfiguration error: %d\n", err);
            continue;
        }
        
        NSLog(@"CGCompleteDisplayConfiguration -------\n");
        
        NSLog(@"\t DONE -- displayID: %d -------------------------------\n\n\n", displayIDs[i]);
//    }
        
    } while(i++, i < displayCount);
    
    NSLog(@"==========================================================\n\n\n\n\n");
    
    return true;
}

bool DisplayLayout::applyLayoutChanges()
{
    
    std::cout << "---------------------- applyLayoutChanges ----------------------" << std::endl;
    
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
        
        std::cout << device->getDeviceId() << ": " << resolution_x << "x" <<resolution_y << std::endl;
		
		// if we have display frames defined for each display, then we will use that...
		if (configureAllDisplaysIndividually) {
            std::cout << "configureAllDisplaysIndividually" << std::endl;
			auto iter = mDeviceFrames.find(device->getDeviceId());
			if (iter != mDeviceFrames.end()) {
				mResWidth = iter->second.width;
				mResHeight = iter->second.height;
                std::cout << "mResWidth * mResHeight " << mResWidth << "x" << mResHeight << std::endl;
			}
		}
		
		// if the resolution is set to something impossible then we don't assign it
		// but we use the default resolution for the rest of the layout...
		if (0 == mResWidth || 0 == mResHeight) {
            
            std::cout << "mResWidth * mResHeight is 0x0" << std::endl;
            
			mResWidth = resolution_x;
			mResHeight = resolution_y;
		}
		// if the chosen resolution does not match the existing resolution, then we must pick the matching display mode and apply it.
		else if (desiredResolutionWidth() != resolution_x || desiredResolutionHeight() != resolution_y)
		{
            
            std::cout << "not matched with desiredResolution " << std::endl;
            std::cout << "desired resolution: " << desiredResolutionWidth() << "x" << desiredResolutionHeight() << std::endl;
            std::cout << "mResWidth * mResHeight " << mResWidth << "x" << mResHeight << std::endl;
            
            bool bw = desiredResolutionWidth() != resolution_x ? true : false;
            std::cout << "width " << bw << std::endl;
            bool bh = desiredResolutionHeight() != resolution_y ? true : false;
            std::cout << "height " << bh << std::endl;
            
            std::cout << "desiredResolutionWidth() " << desiredResolutionWidth() << std::endl;
            std::cout << "desiredResolutionHeight() " << desiredResolutionHeight() << std::endl;
            std::cout << "resolution_x " << resolution_x << std::endl;
            std::cout << "resolution_y " << resolution_y << std::endl;
            
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
        
        std::cout << "configureAllDisplaysIndividually -- what " << std::endl;
        
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
        
        std::cout << "here " << count  << "   desiredRows " << desiredRows() << "   desiredColumns " << desiredColumns() << std::endl;
        
        
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
    
    
    std::cout << "mOrientation : " << mOrientation  << std::endl;
    
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
        
//        CGDirectDisplayID largeDisplay = 69502309;
//        io_service_t service = DisplayDevice::IOServicePortFromCGDisplayID(largeDisplay);
//        IOServiceRequestProbe(service, options);
//        
//        std::cout << "service 1 " << service << std::endl;
        
		for (const DisplayDeviceRef device : mQuery->displays()) {
			CGDirectDisplayID display = device->getDeviceId();

//            std::cout << "deviceid " << display << std::endl;
            
			io_service_t service = CGDisplayIOServicePort(display);
            
            // todo: need to look at IOServicePortFromCGDisplayID to figure out why the return value is not valid
//            io_service_t service = DisplayDevice::IOServicePortFromCGDisplayID(display);
         
            std::cout << "service 2 " << service << "\tdisplay: " << display << std::endl;
            
			result = IOServiceRequestProbe(service, options);
            if(result != kCGErrorSuccess) {
                NSLog(@"IOServiceRequestProbe: error %d\n", result);
            } else {
                NSLog(@"IOServiceRequestProbe: success \n");
            }
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
	
    
    std::cout << "mPersistence : " << mPersistence  << std::endl;
	
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

    if(result != kCGErrorSuccess) {
        NSLog(@"CGCompleteDisplayConfiguration: error %d\n", result);
    } else {
        NSLog(@"CGCompleteDisplayConfiguration: success \n");
    }
    
	CGReleaseAllDisplays();
	
	return success;
}

