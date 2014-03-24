//
//  DisplayConfiguration.h
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/21/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#pragma once

#include <CoreGraphics/CoreGraphics.h>
#include <CoreGraphics/CGDisplayConfiguration.h>

#include <memory>
#include <iostream>

#include "DisplayQuery.h"

class DisplayLayout {
public:
	typedef enum orientation_t {
		NORMAL,
		ROTATE_90,
		ROTATE_180,
		ROTATE_270
	} Orientation;
	
	typedef enum corner_t {
		UPPER_LEFT,
		UPPER_RIGHT,
		LOWER_LEFT,
		LOWER_RIGHT
	} Corner;
	
public:
	DisplayLayout();
	~DisplayLayout();
	
	void setDesiredResolution(const uint32_t _x, const uint32_t _y) { mResX = _x; mResY = _y; }
	uint32_t desiredResolutionX() const { return mResX; }
	uint32_t desiredResolutionY() const { return mResY; }
	
	void setDesiredWidth(const uint8_t width) { mWidth = width; }
	uint8_t desiredWidth() const { return mWidth; }
	
	void setDesiredHeight(const uint8_t height) { mHeight = height; }
	uint8_t desiredHeight() const { return mHeight; }
	
	void setDesiredOrientation(const Orientation orientation) { mOrientation = orientation; }
	Orientation desiredOrientation() const { return mOrientation; }
	
	void setPrimaryDisplay(const Corner display) { mPrimary = display; }
	Corner primaryDisplay() const { return mPrimary; }
	
private:
	uint32_t mResX;
	uint32_t mResY;
	uint8_t mWidth;
	uint8_t mHeight;
	Orientation mOrientation;
	Corner mPrimary;
	
	std::shared_ptr<DisplayQuery> mQuery;
	CGDisplayConfigRef mConfigRef;
};
