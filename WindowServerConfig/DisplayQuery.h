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
	
	std::string toString();
	const std::vector<DisplayDevice>& displays() const { return mDisplays; }
	
private:
	std::vector<DisplayDevice> mDisplays;
};

