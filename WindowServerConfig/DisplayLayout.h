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
#include <unordered_map>

#include "DisplayQuery.h"

/**
 * The DisplayLayout class is designed to accumulate configuration parameters and 
 * apply those settings to all connected displays when applyLayoutChanges() is invoked.
 *
 * @see DisplayDevice
 * @see DisplayQuery
 * @see https://developer.apple.com/library/mac/documentation/graphicsimaging/Conceptual/QuartzDisplayServicesConceptual/Articles/DisplayTransactions.html
 */
class DisplayLayout {
public:
	typedef struct frame_t {
        uint32_t displayID;
        uint32_t serialNumber;
		uint32_t position_x;
		uint32_t position_y;
		uint32_t width;
		uint32_t height;
	} Frame;
	
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
	
	typedef enum persistence_t {
		APPLICATION = 0,
		SESSION = 1,
		PERMANENT = 2
	} Persistence;
	
public:
	//! C-store initializes all internal data
	DisplayLayout();
	//! D-store de-allocs all internal data
	~DisplayLayout();
	
	//! Accessor method for the desired resolution
	void setDesiredResolution(const uint32_t width, const uint32_t height) { mResWidth = width; mResHeight = height; }
	uint32_t desiredResolutionWidth() const { return mResWidth; }
	uint32_t desiredResolutionHeight() const { return mResHeight; }
	
	//! Accessor method for the desired number of columns in a display wall
	void setDesiredColumns(const uint8_t width) { mColumns = width; }
	uint8_t desiredColumns() const { return mColumns; }
	
	//! Accessor method for the desired number of rows in a display wall
	void setDesiredRows(const uint8_t height) { mRows = height; }
	uint8_t desiredRows() const { return mRows; }
	
	//! Accessor method for the desired rotation of the current screen
	void setDesiredOrientation(const Orientation orientation) { mOrientation = orientation; }
	Orientation desiredOrientation() const { return mOrientation; }
	
	//! Assigns specific frame for the display given in the device_id parameter
	void setDesiredFrameForDisplay(const uint32_t device_id, const Frame frame);
	//! Returns the desired frame for the display corresponding to the device_id parameter
	Frame getDesiredFrameForDisplay(const uint32_t device_id);

	// Currently not implemented
	//void setPrimaryDisplay(const Corner display) { mPrimary = display; }
	//Corner primaryDisplay() const { return mPrimary; }
	
	//! Accessor method to enable or disable the permanent or temporary status of the changes
	void setPersistence(const Persistence setting) { mPersistence = setting; }
	Persistence persistence() const { return mPersistence; }
	
	//! Takes the input data and executes the configuration change
	bool applyLayoutChanges();
	
    bool applyChanges(std::vector<Frame> &display_frames);

        
private:
    
	uint32_t mResWidth;
	uint32_t mResHeight;
	uint8_t mColumns;
	uint8_t mRows;
	std::unordered_map<uint32_t, Frame> mDeviceFrames;
	Persistence mPersistence;
	Orientation mOrientation;
	Corner mPrimary;
	
	std::shared_ptr<DisplayQuery> mQuery;
	CGDisplayConfigRef mConfigRef;
};
