//
//  DisplayDevice.h
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/20/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#pragma once

#include <CoreGraphics/CoreGraphics.h>
#include <CoreGraphics/CGDisplayConfiguration.h>

#include <memory>
#include <string>

class DisplayMode {
public:
	DisplayMode(CGDisplayModeRef mode);
	DisplayMode(const CGDirectDisplayID display);
	~DisplayMode();
	
	std::string toString() const;
	
private:
	friend class DisplayDevice;
	
	CGDisplayModeRef modeRef;
	CFTypeID type;
	double refreshRate;
	uint32_t ioFlags;
	uint32_t ioModeId;
	size_t height;
	size_t width;
	CFStringRef copyPixelEncoding;
	bool usableForDesktopGui;
};

class DisplayDevice {
public:
	DisplayDevice(const CGDirectDisplayID display);
	~DisplayDevice();
	
	CGDirectDisplayID getDeviceId() const { return deviceId; }
	CGDisplayModeRef getCurrentDisplayMode() const { return displayMode->modeRef; }
	
	std::string toString() const;
	std::string displayName() const;
	
private:
	CGDirectDisplayID deviceId;
	std::shared_ptr<DisplayMode> displayMode;
	
	CGRect displayBoundary;
	CGColorSpaceRef colorSpace;
	uint32_t gammaTableCapacity;
	CGContextRef drawingContext;
	bool isActive;
	bool isAlwaysInMirrorSet;
	bool isAsleep;
	bool isBuiltin;
	bool isInHWMirrorSet;
	bool isInMirrorSet;
	bool isMain;
	bool isOnline;
	bool isStereo;
	bool usesOpenGLAcceleration;
	double rotation;
	CGSize screenSize;
	uint32_t modelNumber;
	uint32_t serialNumber;
	uint32_t unitNumber;
	uint32_t vendorNumber;
};
