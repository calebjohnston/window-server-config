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
#include <vector>
#include <string>

typedef std::shared_ptr<class DisplayMode> DisplayModeRef;
typedef std::shared_ptr<class DisplayDevice> DisplayDeviceRef;

class DisplayMode {
public:
	DisplayMode() : mModeRef(0) {};
	DisplayMode(CGDisplayModeRef mode);
	DisplayMode(const CGDirectDisplayID display);
	~DisplayMode();
	
	CGDisplayModeRef getNativePtr() const { return mModeRef; }
	uint32_t getWidth() const { return static_cast<uint32_t>(mWidth); }
	uint32_t getHeight() const { return static_cast<uint32_t>(mHeight); }
	bool usableForDesktopGui() const { return mUsableForDesktopGui; }
	std::string toString() const;
	
private:
	friend class DisplayDevice;
	
	CGDisplayModeRef mModeRef;
	CFTypeID mType;
	double mRefreshRate;
	uint32_t mIoFlags;
	uint32_t mIoModeId;
	size_t mHeight;
	size_t mWidth;
	CFStringRef mCopyPixelEncoding;
	bool mUsableForDesktopGui;
};

class DisplayDevice {
public:
	DisplayDevice() {};
	DisplayDevice(const CGDirectDisplayID display);
	~DisplayDevice();
	
	CGDirectDisplayID getDeviceId() const { return mDeviceId; }
	DisplayModeRef getCurrentDisplayMode() const { return mCurrentDisplayMode; }
	const std::vector<DisplayModeRef>& getAllDisplayModes() const { return mAllSupportedDisplayModes; }
	
	std::string toString() const;
	std::string displayName() const;
	
private:
	CGDirectDisplayID mDeviceId;
	DisplayModeRef mCurrentDisplayMode;
	std::vector<DisplayModeRef> mAllSupportedDisplayModes;
	
	CGRect mDisplayBoundary;
	CGColorSpaceRef mColorSpace;
	uint32_t mGammaTableCapacity;
	CGContextRef mDrawingContext;
	bool mIsActive;
	bool mIsAlwaysInMirrorSet;
	bool mIsAsleep;
	bool mIsBuiltin;
	bool mIsInHWMirrorSet;
	bool mIsInMirrorSet;
	bool mIsMain;
	bool mIsOnline;
	bool mIsStereo;
	bool mUsesOpenGLAcceleration;
	double mRotation;
	CGSize mScreenSize;
	uint32_t mModelNumber;
	uint32_t mSerialNumber;
	uint32_t mUnitNumber;
	uint32_t mVendorNumber;
};
