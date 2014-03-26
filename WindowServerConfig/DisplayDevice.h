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

/**
 * The DisplayMode class wraps a collection of native types and primitive
 * data that represents a display mode supported by a display device.
 * Chief among these is the CGDisplayModeRef type defined by Apple's
 * Core Graphics Framework.
 *
 * @see DisplayDevice
 * @see DisplayQuery
 */
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
	
	CGDisplayModeRef mModeRef;	//!< most important native type
	CFTypeID mType;				//!< unique identifier for display mode
	double mRefreshRate;		//!< populated only if device reports it
	uint32_t mIoFlags;			//!< populated by CGDisplayModeGetIOFlags
	uint32_t mIoModeId;			//!< populated by CGDisplayModeGetIODisplayModeID
	size_t mHeight;				//!< resolution height
	size_t mWidth;				//!< resolution width
	CFStringRef mCopyPixelEncoding;	//!< pixel encoding specified in IOKit/graphics/IOGraphicsTypes.h
	bool mUsableForDesktopGui;	//!< TRUE if display is capable of displaying Apple GUI, FALSE otherwise
};

/**
 * The DisplayDevice class essentially represents a physical display
 * and contains all the relevant information for that display. It is
 * used by nearly all other classes in the codebase. Each DisplayDevice
 * is created with a copy of each of the DisplayModes it can draw.
 *
 * @see DisplayMode
 * @see DisplayQuery
 */
class DisplayDevice {
public:
	//! C'stor - initializes all members to empty states
	DisplayDevice();
	//! C'store - performs all initial query operations
	DisplayDevice(const CGDirectDisplayID display);
	//! D'store - Releases any memory allocated by constructors
	~DisplayDevice();
	
	//! Returns device ID number
	CGDirectDisplayID getDeviceId() const { return mDeviceId; }
	//! Returns smart pointer to currently active display mode
	DisplayModeRef getCurrentDisplayMode() const { return mCurrentDisplayMode; }
	//! Returns list of all display modes supported by the display device
	const std::vector<DisplayModeRef>& getAllDisplayModes() const { return mAllSupportedDisplayModes; }
	
	//! Returns string representation of the display device
	std::string toString() const;
	//! Returns product name representing the display device
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
