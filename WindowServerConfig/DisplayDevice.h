//
//  DisplayDevice.h
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/20/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayMode : NSObject

@property (nonatomic) CGDisplayModeRef modeRef;
@property (nonatomic) CFTypeID type;
@property (nonatomic) double refreshRate;
@property (nonatomic) uint32_t ioFlags;
@property (nonatomic) uint32_t ioModeId;
@property (nonatomic) size_t height;
@property (nonatomic) size_t width;
@property (nonatomic) CFStringRef copyPixelEncoding;
@property (nonatomic) BOOL usableForDesktopGui;

- (id) initWithDisplayMode:(CGDisplayModeRef) mode;
- (id) initWithDisplay:(CGDirectDisplayID) display;
- (NSString*) toNSString;

@end

@interface DisplayDevice : NSObject
{
	CGDirectDisplayID deviceId;
	DisplayMode* displayMode;
	
//	CGDirectDisplayID CGDisplayMirrorsDisplay;
//	CGError CGDisplayMoveCursorToPoint;	// cool!
	
}

@property (nonatomic) CGRect displayBoundary;
@property (nonatomic) CGColorSpaceRef colorSpace;
@property (nonatomic) uint32_t gammaTableCapacity;
@property (nonatomic) CGContextRef drawingContext;
@property (nonatomic) BOOL isActive;
@property (nonatomic) BOOL isAlwaysInMirrorSet;
@property (nonatomic) BOOL isAsleep;
@property (nonatomic) BOOL isBuiltin;
@property (nonatomic) BOOL isInHWMirrorSet;
@property (nonatomic) BOOL isInMirrorSet;
@property (nonatomic) BOOL isMain;
@property (nonatomic) BOOL isOnline;
@property (nonatomic) BOOL isStereo;
@property (nonatomic) BOOL usesOpenGLAcceleration;
@property (nonatomic) double rotation;
@property (nonatomic) CGSize screenSize;
@property (nonatomic) uint32_t modelNumber;
@property (nonatomic) uint32_t serialNumber;
@property (nonatomic) uint32_t unitNumber;
@property (nonatomic) uint32_t vendorNumber;

- (id) initWithDisplay:(CGDirectDisplayID) display;
- (CGDirectDisplayID) getDeviceId;
- (CGDisplayModeRef) getMode;
- (NSString*) toNSString;

@end