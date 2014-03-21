//
//  DisplayConfiguration.h
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/21/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#pragma once

#include <memory>
#include <iostream>

#include "DisplayQuery.h"

class DisplayConfiguration {
public:
	DisplayConfiguration();
	~DisplayConfiguration();
	
private:
	std::shared_ptr<DisplayQuery> mQuery;
};
