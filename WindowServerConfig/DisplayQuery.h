//
//  DisplayQuery.h
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/20/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#pragma once

#ifdef __OBJC__
	@class DisplayDevice;
#else
	class DisplayDevice;
#endif

#include <set>
#include <vector>

#include "DisplayQuery.h"

class DisplayQuery {
public:
	DisplayQuery();
	~DisplayQuery();
	
	std::string toString();
	const std::vector<DisplayDevice*>& displays() const { return mDisplays; }
	
private:
	std::vector<DisplayDevice*> mDisplays;
};

