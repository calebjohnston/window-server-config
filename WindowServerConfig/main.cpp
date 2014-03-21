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
	std::vector<int> resolution;
	std::string rotation;
	
	try {
		po::options_description desc("Allowed options");
		desc.add_options()
		("help,H", "produce help message")
		("query,Q", "query displays")
		("rotation,O", po::value<std::string>(&rotation), "desired rotation in degrees 0,90,180, or 270")
		("resolution,R", po::value< std::vector<int> >(&resolution)->multitoken(), "[ width height ]")
		("refresh,F", po::value<double>(&refresh_rate), "refresh rate")
		("width,W", po::value<int>(&desired_width)->default_value(1), "display arrangement width (in displays)")
		("height,H", po::value<int>(&desired_height)->default_value(1), "display arrangement height (in displays)");
		
		po::variables_map vm;
		po::store(po::command_line_parser(argc, argv).options(desc).style(po::command_line_style::default_style
																		  | po::command_line_style::allow_slash_for_short
																		  | po::command_line_style::allow_long_disguise).run(), vm);
		
		po::notify(vm);
		
		if (vm.count("help")) {
			std::cout << "Usage: options_description [options]" << std::endl;
			std::cout << desc << std::endl;
			return 0;
		}
		
//		if (vm.count("output-name")) {
//			std::cout << "Output name is: " << vm["output-name"].as<std::string>() << std::endl;
//		}
//		
//		if (vm.count("output-format")) {
//			std::cout << "Output format is: " << vm["output-format"].as<std::string>() << std::endl;
//		}
		
		if (vm.count("query")) {
			DisplayQuery dp;
			std::cout << dp.toString() << std::endl;
			return 0;
		}
	}
	catch(std::exception& e) {
		return 1;
	}
	catch(...) {
	}
	
	DisplayLayout dl;
	
    return 0;
}

