//
//  DisplayDevice.m
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/20/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#import "DisplayDevice.h"

@implementation DisplayMode : NSObject

- (id) initWithDisplay:(CGDirectDisplayID) display
{
	self = [super init];
    if (self) {
		//CGError err = CGDisplayGetDisplayMode(display, self.modeRef, NULL);
		self.modeRef = CGDisplayCopyDisplayMode(display);
		CGDisplayModeRetain(self.modeRef);
		
		//if (kCGErrorSuccess == err) {
			self.type = CGDisplayModeGetTypeID();
			self.refreshRate = CGDisplayModeGetRefreshRate(self.modeRef);
			self.ioFlags = CGDisplayModeGetIOFlags(self.modeRef);
			self.ioModeId = CGDisplayModeGetIODisplayModeID(self.modeRef);
			self.height = CGDisplayModeGetHeight(self.modeRef);
			self.width = CGDisplayModeGetWidth(self.modeRef);
			self.copyPixelEncoding = CGDisplayModeCopyPixelEncoding(self.modeRef);
			self.usableForDesktopGui = CGDisplayModeIsUsableForDesktopGUI(self.modeRef);
//		}
//		else {
//			NSLog(@"Error creating DisplayMode: %i", err);
//		}
    }
	
	return self;
}

- (NSString*) toUTF8String
{
	const char str[] = "hello";
	NSString* output = [NSString stringWithUTF8String:str];
	
	// append info...
	
	return output;
}

- (void) dealloc
{
	[super dealloc];
	
	CGDisplayModeRelease(self.modeRef);
}

@end

@implementation DisplayDevice

- (id) initWithDisplay:(CGDirectDisplayID) display
{
	self = [super init];
    if (self) {
		deviceId = display;
		self.colorSpace = CGDisplayCopyColorSpace(deviceId);
		self.gammaTableCapacity = CGDisplayGammaTableCapacity(deviceId);
		self.drawingContext = CGDisplayGetDrawingContext(deviceId);
		self.isActive = CGDisplayIsActive(deviceId);
		self.isAlwaysInMirrorSet = CGDisplayIsAlwaysInMirrorSet(deviceId);
		self.isAsleep = CGDisplayIsAsleep(deviceId);
		self.isBuiltin = CGDisplayIsBuiltin(deviceId);
		self.isInHWMirrorSet = CGDisplayIsInHWMirrorSet(deviceId);
		self.isInMirrorSet = CGDisplayIsInMirrorSet(deviceId);
		self.isMain = CGDisplayIsMain(deviceId);
		self.isOnline = CGDisplayIsOnline(deviceId);
		self.isStereo = CGDisplayIsStereo(deviceId);
		self.usesOpenGLAcceleration = CGDisplayUsesOpenGLAcceleration(deviceId);
		self.rotation = CGDisplayRotation(deviceId);
		self.screenSize = CGDisplayScreenSize(deviceId); // in millimeters
		self.modelNumber = CGDisplayModelNumber(deviceId);
		self.serialNumber = CGDisplaySerialNumber(deviceId);
		self.unitNumber = CGDisplayUnitNumber(deviceId);
		self.vendorNumber = CGDisplayVendorNumber(deviceId);
		self.displayBoundary = CGDisplayBounds(deviceId);
		
		displayMode = [[DisplayMode alloc] initWithDisplay:deviceId];
	}
	
	return self;
}

- (CGDirectDisplayID) getDeviceId
{
	return deviceId;
}

- (CGDisplayModeRef) getMode
{
	return displayMode.modeRef;
}

- (NSString*) toUTF8String
{
	NSString* fmt = @"%@ %i\n\t %@ %i\n\t %@ %i\n\t %@ %i\n\t %@ %i\n\t %@ (%.0f x %.0f)\n\t %@ %.2f\n\t %@ %@\n\t %@ %@\n\t %@ %@\n\t %@ %@\n\t %@ %@\n\t %@ [%.0f,%.0f %.0fx%.0f]\n";
	NSString* output = [NSString stringWithFormat:fmt,
						@"Device ID:", deviceId,
						@"Model Number:\t", self.modelNumber,
						@"Serial Number:\t", self.serialNumber,
						@"Unit Number:\t", self.unitNumber,
						@"Vendor Number:\t", self.vendorNumber,
						@"Screen Size:\t", self.screenSize.width, self.screenSize.height,
						@"Rotation:\t", self.rotation,
						@"Is Active:\t", (self.isActive ? @"True" : @"False"),
						@"Is Online:\t", (self.isOnline ? @"True" : @"False"),
						@"Is Built-in:\t", (self.isBuiltin ? @"True" : @"False"),
						@"Is Primary:\t", (self.isMain ? @"True" : @"False"),
						@"HW Accelerated:", (self.usesOpenGLAcceleration ? @"True" : @"False"),
						@"Bounds:\t", self.displayBoundary.origin.x, self.displayBoundary.origin.y, self.displayBoundary.size.width, self.displayBoundary.size.height ];
	
	return output;
}

@end
