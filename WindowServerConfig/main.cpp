//
//  main.cpp
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/20/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#include <boost/program_options.hpp>
#include <boost/format.hpp>

#include <vector>
#include <string>
#include <thread>
#include <chrono>
#include <exception>
#include <iostream>

#include "DisplayQuery.h"
#include "DisplayLayout.h"

namespace po = boost::program_options;

int main(int argc, const char * argv[])
{
	int desired_cols;
	int desired_rows;
	double refresh_rate;
	int device_id;
	std::vector<int32_t> resolution;
	std::string rotation_str;
	int persistence;
	
	try {
		po::options_description desc("Allowed options");
		desc.add_options()
		("help,H", "produce help message")
		("query,Q", "get all connected displays")
		("modes,M", po::value<int>(&device_id), "query device modes for device id")
		("rotation,O", po::value<std::string>(&rotation_str), "desired rotation in degrees (0, 90, 180, or 270)")
		("resolution,S", po::value< std::vector<int> >(&resolution)->multitoken(), "[ width height ]")
		("refresh,F", po::value<double>(&refresh_rate), "refresh rate")
		("columns,C", po::value<int>(&desired_cols)->default_value(1), "number of columns of displays")
		("rows,R", po::value<int>(&desired_rows)->default_value(1), "number of rows of displays")
		("persistence,P", po::value<int>(&persistence)->default_value(1), "setting persistence (0=temporary or 1=permanent)");
		
		po::variables_map var_map;
		po::store(po::command_line_parser(argc, argv).options(desc).style(po::command_line_style::default_style
																		  | po::command_line_style::allow_slash_for_short
																		  | po::command_line_style::allow_long_disguise).run(), var_map);
		
		po::notify(var_map);
		
		// make regular device query...
		if (var_map.count("query")) {
			DisplayQuery query;
			
			std::string output;
			for (const DisplayDeviceRef device : query.displays()) {
				output += device->toString();
				output += "\n";
			}
			std::cout << output << std::endl;
			
			return 0;
		}
		
		// make device query for all display modes using given device ID
		else if (var_map.count("modes")) {
			DisplayQuery query;
			
			// check input device id...
			//if (var_map["modes"]) {
			//	std::cout << "Must specify a device ID to query. " << std::endl;
			//	return 1;
			//}
			std::string output;
			int32_t dev_id = var_map["modes"].as<int32_t>();
			const DisplayDeviceRef device = query.getDisplay(dev_id);
			if (!device) {
				std::cout << "There is no connected device with the device ID: " << dev_id << std::endl;
				std::cout << "Query failed." << std::endl;
				return -1;
			}
			
			// print results...
			std::cout << "There are " << device->getAllDisplayModes().size() << " display modes for " << device->displayName() << std::endl;
			for (const DisplayModeRef mode : device->getAllDisplayModes()) {
				output += "\t" + mode->toString();
				output += "\n";
			}
			std::cout << output << std::endl;
			
			return 0;
		}
		
//		if (var_map.count("rotation") || var_map.count("resolution") ||
//			var_map.count("refresh") || var_map.count("columns") || var_map.count("rows"))
		else if (! var_map.count("help"))
		{
			DisplayLayout display_layout;
			
			// set display arrangement persistence
			if (persistence >= 0 && persistence < 2) {
				persistence += 1;
			}
			display_layout.setPersistence(static_cast<DisplayLayout::Persistence>(persistence));
			
			// set display wall dimensions...
			if (desired_rows > 0) display_layout.setDesiredRows(desired_rows);
			if (desired_cols > 0) display_layout.setDesiredColumns(desired_cols);
			
			// set display orientation... NOT YET IMPLEMENTED!!
			DisplayLayout::Orientation rotation;
			if ("90" == rotation_str) {
				rotation = DisplayLayout::ROTATE_90;
			}
			else if ("180" == rotation_str) {
				rotation = DisplayLayout::ROTATE_180;
			}
			else if ("270" == rotation_str) {
				rotation = DisplayLayout::ROTATE_270;
			}
			else {
				rotation = DisplayLayout::NORMAL;
			}
			display_layout.setDesiredOrientation(rotation);
			
			// set display resolution...
			if (var_map.count("resolution")) {
				display_layout.setDesiredResolution(resolution[0], resolution[1]);
			}
			
			bool success = display_layout.applyLayoutChanges();
			
			return success? 0: 1;
		}
	
		std::cout << "Usage: " << argv[0] << " [options]" << std::endl;
		std::cout << desc << std::endl;
	}
	catch(std::exception& e) {
		return 1;
	}
	catch(...) {
		return 2;
	}
	
    return 0;
}

