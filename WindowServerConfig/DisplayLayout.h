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
	
	void setDesiredResolution(const uint32_t width, const uint32_t height) { mResWidth = width; mResHeight = height; }
	uint32_t desiredResolutionWidth() const { return mResWidth; }
	uint32_t desiredResolutionHeight() const { return mResHeight; }
	
	void setDesiredColumns(const uint8_t width) { mColumns = width; }
	uint8_t desiredColumns() const { return mColumns; }
	
	void setDesiredRows(const uint8_t height) { mRows = height; }
	uint8_t desiredRows() const { return mRows; }
	
	void setDesiredOrientation(const Orientation orientation) { mOrientation = orientation; }
	Orientation desiredOrientation() const { return mOrientation; }
	
	void setPrimaryDisplay(const Corner display) { mPrimary = display; }
	Corner primaryDisplay() const { return mPrimary; }
	
	bool applyLayoutChanges();
	
private:
	uint32_t mResWidth;
	uint32_t mResHeight;
	uint8_t mColumns;
	uint8_t mRows;
	Orientation mOrientation;
	Corner mPrimary;
	
	std::shared_ptr<DisplayQuery> mQuery;
	CGDisplayConfigRef mConfigRef;
};
