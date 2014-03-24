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

class DisplayQuery {
public:
	DisplayQuery();
	~DisplayQuery();
	
	const DisplayDeviceRef getDisplay(const int32_t deviceId) const;
	
	const std::vector<DisplayDeviceRef>& displays() const { return mDisplays; }
	
private:
	std::vector<DisplayDeviceRef> mDisplays;
};

