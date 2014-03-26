//
//  DisplayQuery.h
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/20/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#pragma once

#include <vector>

#include "DisplayDevice.h"
#include "DisplayQuery.h"

/**
 * The DisplayQuery class contains a collection of displays that
 * have been populated with information from the operating system.
 *
 * @see DisplayDevice
 * @see DisplayLayout
 */
class DisplayQuery {
public:
	DisplayQuery();
	~DisplayQuery();
	
	/** 
	 * Returns const reference to display device data denoted by the given ID. 
	 * If no such device is found, an empty shared pointer is returned.
	 */
	const DisplayDeviceRef getDisplay(const int32_t deviceId) const;
	
	//! Returns const reference to the container filled with display device data
	const std::vector<DisplayDeviceRef>& displays() const { return mDisplays; }
	
private:
	std::vector<DisplayDeviceRef> mDisplays;
};

