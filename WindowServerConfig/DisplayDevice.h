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
#import <IOKit/graphics/IOGraphicsLib.h>

#include <memory>
#include <vector>
#include <string>
#include <sstream>

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
	std::string displayName(CGDirectDisplayID displayID) const;
    
//    static io_service_t IOServicePortFromCGDisplayID(CGDirectDisplayID displayID);

    
    // Returns the io_service_t corresponding to a CG display ID, or 0 on failure.
    // The io_service_t should be released with IOObjectRelease when not needed.
    //
    static io_service_t IOServicePortFromCGDisplayID(CGDirectDisplayID displayID)
    {
        std::stringstream output_str;
        output_str << "IOServicePortFromCGDisplayID " << displayID << std::endl;
        
        io_iterator_t iter;
        io_service_t serv, servicePort = 0;
        
        CFMutableDictionaryRef matching = IOServiceMatching("IODisplayConnect");
        
        // releases matching for us
        kern_return_t err = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                         matching,
                                                         &iter);
        if (err) return 0;
        
        while ((serv = IOIteratorNext(iter)) != 0)
        {
            
            output_str << "serv:\t" << serv << std::endl;

            CFDictionaryRef info;
            CFIndex vendorID, productID;
            CFNumberRef vendorIDRef, productIDRef;
            Boolean success;
            
            info = IODisplayCreateInfoDictionary(serv, kIODisplayOnlyPreferredName);
            
            //const void *CFDictionaryGetValue(CFDictionaryRef theDict, const void *key);
            
            vendorIDRef = (CFNumberRef) CFDictionaryGetValue(info, CFSTR(kDisplayVendorID));
            productIDRef = (CFNumberRef) CFDictionaryGetValue(info, CFSTR(kDisplayProductID));
            
            success = CFNumberGetValue(vendorIDRef, kCFNumberCFIndexType,
                                       &vendorID);
            success &= CFNumberGetValue(productIDRef, kCFNumberCFIndexType,
                                        &productID);
            
            if (!success)
            {
                CFRelease(info);
                continue;
            }
            
            if (CGDisplayVendorNumber(displayID) != vendorID ||
                CGDisplayModelNumber(displayID) != productID)
            {
                CFRelease(info);
                continue;
            }
            
            // we're a match
            servicePort = serv;
            CFRelease(info);
            break;
        }
        
        IOObjectRelease(iter);
        return servicePort;
    }

	
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
