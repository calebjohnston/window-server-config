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
#include "DisplayConfiguration.h"

namespace po = boost::program_options;

int main(int argc, const char * argv[])
{
//	float dt = 0.1;
//	std::vector<int> grid_dims(3, 50);	// grid dimensions
//	
//	float gvec[3] = {0.0, 0.0, -1.0}; // gravitational field (constant)
//	
//	float cg_tol = pow( DBL_EPSILON, 0.5 );
//	unsigned cg_maxiter = 200;
//	std::string output_prefix = "density_export_";
//	int window_width = 1280;
//	int window_height = 1024;
	
	try {
		po::options_description desc("Allowed options");
		desc.add_options()
		("help,H", "produce help message")
		("query,Q", "query displays");
//		("output-format,O", po::value<std::string>(), "output format")
//		("output-name,N", po::value<std::string>(&output_prefix), "output file name PREFIX")
//		("grid,G", po::value< std::vector<int> >(&grid_dims)->multitoken(), "[ X Y Z ]")
//		("gravity,Z", po::value<float>(&gvec[2]), "z gravity component ")
//		("solver-tol,R", po::value<float>(&cg_tol), "linear solver convergence tolerance")
//		("timestep,T", po::value<float>(&dt), "timestep update")
//		("solver-iterations,I", po::value<unsigned>(&cg_maxiter)->default_value(200), "maximum solver iterations")
//		("win-width,W", po::value<int>(&window_width)->default_value(512), "Glut window width")
//		("win-height,E", po::value<int>(&window_height)->default_value(512), "Glut window height");
		
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
	
	DisplayConfiguration* dc = new DisplayConfiguration();
	delete dc;
	
    return 0;
}

