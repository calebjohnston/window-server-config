//
//  main.cpp
//  WindowServerConfig
//
//  Created by Caleb Johnston on 3/20/14.
//  Copyright (c) 2014 Caleb Johnston. All rights reserved.
//

#include <boost/assign/list_of.hpp>
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
	int desired_cols = 0;
	int desired_rows = 0;
	double refresh_rate = 0.0;
	int device_id = 0;
	std::vector<int32_t> display_data;
	std::vector<int32_t> resolution;
	std::string rotation_str;
	int persistence = 0;
	
	// displaycfg -X <id> <x,y> -X <id> <x,y>
	
	try {
		po::options_description desc("Allowed options", 100);
		desc.add_options()
		("help,H", "produce help message")
		("query,Q", "get all connected displays")
		("modes,M", po::value<int>(&device_id), "query device modes for device id")
		("rotation,O", po::value<std::string>(&rotation_str), "desired rotation in degrees (0, 90, 180, 270)")
		("resolution,S", po::value< std::vector<int> >(&resolution)->multitoken(), "target resolution ( width height )")
		("refresh,F", po::value<double>(&refresh_rate), "refresh rate")
		("columns,C", po::value<int>(&desired_cols)->default_value(1), "number of columns of displays")
		("rows,R", po::value<int>(&desired_rows)->default_value(1), "number of rows of displays")
		("persistence,P", po::value<int>(&persistence)->default_value(1), "configuration persistence (0=temporary, 1=permanent)")
		("display,D", po::value< std::vector<int32_t> >(&display_data)->composing()->multitoken(), "Configure each display \
		 individually. Expects a sequence of 5-tuples, each one must contain the device ID, the global x coordinate, the \
		 global y coordinate, the canvas width, and the canvas height (in that order). This option will cause the inputs for\
		 columns and rows to be ignored.");
		
		po::variables_map var_map;
		const po::positional_options_description position;
		po::command_line_parser parser = po::command_line_parser( argc, argv );
		parser.options( desc ).positional( position ).style( po::command_line_style::unix_style |
															 po::command_line_style::allow_slash_for_short |
															 po::command_line_style::allow_long_disguise );
		
		po::store( parser.run(), var_map );
		po::notify(var_map);
		
		// make regular device query...
		if (var_map.count("help")) {
			std::cout << "Usage: " << argv[0] << " [options]" << std::endl;
			std::cout << desc << std::endl;
			return 0;
		}
		// handle controlling display modes per screen
		else if (var_map.count("display")) {
			DisplayQuery query;
			
			std::vector<DisplayLayout::Frame> display_frames;
			std::vector<uint32_t> display_ids;
			
			int index = 0;
			int coordinate_capture = 0;
			DisplayLayout::Frame* temp_frame = nullptr;
			for (int32_t display_datum : display_data) {
				if (index % 5 == 0) {
					display_ids.push_back( static_cast<uint32_t>( display_datum ) );
					//std::cout << "  " << index << " / display id: " << display_datum << std::endl;
					temp_frame = new DisplayLayout::Frame();
				}
				else if (coordinate_capture == 0) {
					temp_frame->position_x = display_datum;
					coordinate_capture++;
				}
				else if (coordinate_capture == 1) {
					temp_frame->position_y = display_datum;
					coordinate_capture++;
				}
				else if (coordinate_capture == 2) {
					temp_frame->width = display_datum;
					coordinate_capture++;
				}
				else if (coordinate_capture == 3) {
					temp_frame->height = display_datum;
					coordinate_capture = 0;
					
					display_frames.push_back( *temp_frame );
					//std::cout << "  " << index << " frame: " << temp_frame->position_x << "," << temp_frame->position_y;
					//std::cout << "  " << temp_frame->width << "x" << temp_frame->height << std::endl;
				}
				
				index++;
			}
			
			if (display_frames.size() != display_ids.size()) {
				std::cerr << "Could not parse input display parameters." << std::endl;
				return 1;
			}
			
			DisplayLayout display_layout;
			auto iter = display_frames.begin();
			for (uint32_t device_id : display_ids) {
				display_layout.setDesiredFrameForDisplay(device_id, *iter);
				iter++;
			}
			
			bool success = display_layout.applyLayoutChanges();
			
			return success? 0: 1;
		}
		// handle general query
		else if (var_map.count("query")) {
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
		else if (argc > 1) {
			DisplayLayout display_layout;
			
			// set display arrangement persistence
			if (persistence >= 0 && persistence < 2) {
				persistence += 1;
			}
			display_layout.setPersistence(static_cast<DisplayLayout::Persistence>(persistence));
			
			// set display wall dimensions...
			if (desired_rows > 0) display_layout.setDesiredRows(desired_rows);
			if (desired_cols > 0) display_layout.setDesiredColumns(desired_cols);
			
			// set display orientation... 
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
		else {
			std::cout << "Usage: " << argv[0] << " [options]" << std::endl;
			std::cout << desc << std::endl;
		}
	}
	catch(std::exception& e) {
		std::cerr << "Exception: " << e.what() << std::endl;
		return 1;
	}
	catch(...) {
		return 2;
	}
	
    return 0;
}

