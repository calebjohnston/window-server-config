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
	
//	float gvec[3] = {0.0, 0.0, -1.0};
//	std::string output_prefix = "export_";
	int desired_width;
	int desired_height;
	double refresh_rate;
	int device_id;
	std::vector<int32_t> resolution;
	std::string rotation_str;
	
	try {
		po::options_description desc("Allowed options");
		desc.add_options()
		("help,H", "produce help message")
		("query,Q", "get all connected displays")
		("modes,M", po::value<int>(&device_id), "query device modes for device id")
		("rotation,O", po::value<std::string>(&rotation_str), "desired rotation in degrees: 0, 90, 180, or 270")
		("resolution,R", po::value< std::vector<int> >(&resolution)->multitoken(), "[ width height ]")
		("refresh,F", po::value<double>(&refresh_rate), "refresh rate")
		("width,W", po::value<int>(&desired_width)->default_value(1), "display arrangement width (in displays)")
		("height,H", po::value<int>(&desired_height)->default_value(1), "display arrangement height (in displays)");
		
		po::variables_map var_map;
		po::store(po::command_line_parser(argc, argv).options(desc).style(po::command_line_style::default_style
																		  | po::command_line_style::allow_slash_for_short
																		  | po::command_line_style::allow_long_disguise).run(), var_map);
		
		po::notify(var_map);
		
		DisplayQuery dp;
		
		// make regular device query...
		if (var_map.count("query")) {
			std::string output;
			for (const DisplayDeviceRef device : dp.displays()) {
				output += device->toString();
				output += "\n";
			}
			std::cout << output << std::endl;
			
			return 0;
		}
		
		// make device query for all display modes using given device ID
		if (var_map.count("modes")) {
			// check input device id...
			//if (var_map["modes"]) {
			//	std::cout << "Must specify a device ID to query. " << std::endl;
			//	return 1;
			//}
			std::string output;
			int32_t dev_id = var_map["modes"].as<int32_t>();
			const DisplayDeviceRef device = dp.getDisplay(dev_id);
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
		
		if (var_map.count("rotation") || var_map.count("resolution") ||
			var_map.count("refresh") || var_map.count("width") || var_map.count("height"))
		{
			DisplayLayout dl;
			dl.setDesiredHeight(desired_height);
			dl.setDesiredWidth(desired_width);
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
			dl.setDesiredOrientation(rotation);
			dl.setDesiredResolution(resolution[0], resolution[1]);
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

