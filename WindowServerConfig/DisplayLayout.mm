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
:	mOrientation(NORMAL), mPrimary(UPPER_LEFT), mColumns(1), mRows(1), mResWidth(0), mResHeight(0), mFreq(60), mPersistence(PERMANENT)
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

bool operator<( const DisplayLayout::Frame& a, const DisplayLayout::Frame& b ){
	if ( a.position_x < b.position_x ) return true;
	else if ( a.position_x == b.position_x && a.position_y < b.position_y ) return true;
	return false;
}

bool DisplayLayout::applyChanges(std::vector<Frame> &display_frames) {
	
	CGError err;
	
	// Get displays
	
	std::vector<Frame> displays;
	
	uint32_t displayCount;
	err = CGGetActiveDisplayList(0, 0, &displayCount);
	if(err != kCGErrorSuccess) {
		NSLog(@"CGGetActiveDisplayList error: %d\n", err);
		return false;
	}
	
	CGDirectDisplayID* displayIDs = (CGDirectDisplayID*) malloc(displayCount * sizeof(CGDirectDisplayID));
	err = CGGetActiveDisplayList(displayCount, displayIDs, &displayCount);
	if(err != kCGErrorSuccess) {
		NSLog(@"CGGetActiveDisplayList error: %d\n", err);
		return false;
	}
	
	if(display_frames.size() != 0) {
		
		for( int i = 0; i < displayCount; i++) {
			auto found = std::find_if( display_frames.begin(), display_frames.end(),
									  [&]( const Frame &frame){
										  return frame.unitNumber == CGDisplayUnitNumber(displayIDs[i]);
									  });
			if( found != display_frames.end() ) {
				found->displayID = displayIDs[i];
			}
		}
		
		displays = display_frames;
		
	}
	else {
		
		for( int i = 0; i < displayCount; i++ ) {
			Frame* frame = new Frame();
			frame->displayID = displayIDs[i];
			frame->serialNumber = CGDisplaySerialNumber(displayIDs[i]);
			frame->unitNumber = CGDisplayUnitNumber(displayIDs[i]);
			frame->position_x = -1;
			frame->position_y = -1;
			frame->width = mResWidth;
			frame->height = mResHeight;
			displays.push_back( *frame );
		}
	}
	
	// sort displays by position
	std::sort(displays.begin(), displays.end());
	
	// set display mode
	for( std::vector<Frame>::iterator iter = displays.begin(); iter != displays.end(); ++iter ) {
		
		CGDirectDisplayID displayID = (*iter).displayID;
		if( CGDisplayRotation(displayID) != mOrientation ) {
			
			io_service_t service = CGDisplayIOServicePort(displayID);
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
				NSLog(@"IOServiceRequestProbe -- DisplayID: %d\terror: %d \n\n\n", displayID, err);
				return false;
			}
			
			// Need to pause for a bit for the CG system to catch up
			sleep(3);
		}
	}
	
	int mainDisplayWidth = 0;
	int mainDisplayHeight = 0;
	
	CGDisplayConfigRef config;
	err = CGBeginDisplayConfiguration(&config);
	if(err != kCGErrorSuccess) {
		NSLog(@"CGBeginDisplayConfiguration error: %d\n", err);
		return false;
	}
	
	//    NSLog(@"CGBeginDisplayConfiguration\n");
	
	std::vector<Frame>::iterator display = displays.begin();
	do {
		
		CGDirectDisplayID displayID = (*display).displayID;
		uint32_t unitNumber = (*display).unitNumber;
		uint32_t targetWidth = (*display).width;
		uint32_t targetHeight = (*display).height;
		uint32_t targetX = (*display).position_x;
		uint32_t targetY = (*display).position_y;
		int index = (int)( display - displays.begin() );
		
		//		NSLog(@"displayId: %d, unitNumber: %d, width: %d, height: %d, x: %d, y: %d", displayID, unitNumber, targetWidth, targetHeight, targetX, targetY);
		//		NSLog(@"mResWidth: %d, mResHeight: %d", mResWidth, mResHeight);
		
		if( ( mResWidth == 0 && targetX == -1 ) || ( mResHeight ==0 && targetY == -1 ) ) continue;
		
		CFArrayRef displayModes = CGDisplayCopyAllDisplayModes(displayID, 0);
		if(!displayModes) {
			NSLog(@"CGDisplayCopyAllDisplayModes not found\n");
			continue;
		}
		
		CGDisplayModeRef desiredMode = nil;
		int display_count = (int) CFArrayGetCount(displayModes);
		for(int j=0, n = display_count; j<n; j++) {
			
			CGDisplayModeRef mode = (CGDisplayModeRef) CFArrayGetValueAtIndex(displayModes, j);
			size_t width = CGDisplayModeGetWidth(mode);
			size_t height = CGDisplayModeGetHeight(mode);
			//            int freq = CGDisplayModeGetRefreshRate(mode);
			
			//			NSLog(@"[DisplayMode] width: %zu, height: %zu, freq: %d", width, height, freq);
			
			bool bUsableForDesktopGui = CGDisplayModeIsUsableForDesktopGUI(mode);
			if(!bUsableForDesktopGui) continue;
			
			if( (mOrientation % 180 != 0 && width > height) || (mOrientation % 180 == 0 && width < height) ) continue;
			
			// todo: check the freq
			// comment this out because sometimes the freq not found.
			if(targetWidth == width && targetHeight == height ) { //&& freq == mFreq) {
				desiredMode = mode;
				break;
			}
		}
		
		CFRelease(displayModes);
		
		if(desiredMode == nil) {
			NSLog(@"%d x %d not found\n", targetWidth, targetHeight);
			continue;
		}
		
		err = CGConfigureDisplayWithDisplayMode(config, displayID, desiredMode, 0);
		if(err != kCGErrorSuccess) {
			NSLog(@"CGConfigureDisplayWithDisplayMode[displayId: %d, unitNumber: %d] error: %d\n", displayID, unitNumber, err);
			continue;
		}
		
		if( index == 0 ) { // main display
			mainDisplayWidth = desiredResolutionWidth();
			mainDisplayHeight = desiredResolutionHeight();
		}
		
		if( mRows > 1 || mColumns > 1 ) {
			if( targetX != -1 && targetY != -1 ) {
				err = CGConfigureDisplayOrigin(config, displayID, targetX, targetY);
				if(err != kCGErrorSuccess)
					NSLog(@"CGConfigureDisplayOrigin error: %d\n", err);
			}
			else {
				err = CGConfigureDisplayOrigin(config, displayID, mainDisplayWidth * ( index % mColumns ), mainDisplayHeight * ( index / mColumns ));
				if(err != kCGErrorSuccess)
					NSLog(@"CGConfigureDisplayOriginerror: %d\n", err);
			}
			
			if(err != kCGErrorSuccess) {
				NSLog(@"CGConfigureDisplayOrigin error: %d\n", err);
				continue;
			}
		}
	} while( ++display, display != displays.end() );
	
	err = CGCompleteDisplayConfiguration(config, kCGConfigureForSession);
	if(err != kCGErrorSuccess) {
		NSLog(@"CGCompleteDisplayConfiguration error: %d\n", err);
		return false;
	}
	
	//    NSLog(@"CGCompleteDisplayConfiguration\n");
	
	CGReleaseAllDisplays();
	
	if(err != kCGErrorSuccess) {
		NSLog(@"CGReleaseAllDisplays error: %d\n", err);
		return false;
	}
	
	return true;
}