#-----------------------------------------------------------
# Abort if design already exists
#-----------------------------------------------------------
set proj_name "proj"
if { [file exists ${proj_name}] == 1 } {
	puts "Aborting. Project already exists"
	exit -1
}

#-----------------------------------------------------------
# Create project
#-----------------------------------------------------------
create_project ${proj_name} "build/${proj_name}" -part xczu9eg-ffvb1156-2-e
set_property BOARD_PART xilinx.com:zcu102:part0:3.4 [current_project]

#-----------------------------------------------------------
# Add HDL source to design
#-----------------------------------------------------------
#import_files -norecurse -fileset sources_1 "rtl"

#-----------------------------------------------------------
# Add xdc constraints to design
#-----------------------------------------------------------
import_files -norecurse -fileset constrs_1 "xdc"

#-----------------------------------------------------------
# Create BD source
#-----------------------------------------------------------
source "xsa_scripts/bd.tcl"
validate_bd_design
save_bd_design

#-----------------------------------------------------------
# Generate BD output products
#-----------------------------------------------------------
generate_target all [get_files "build/${proj_name}/${proj_name}.srcs/sources_1/bd/design_1/design_1.bd"]
make_wrapper -files [get_files "build/${proj_name}/${proj_name}.srcs/sources_1/bd/design_1/design_1.bd"] -top
import_files -force -norecurse "build/${proj_name}/${proj_name}.srcs/sources_1/bd/design_1/hdl/design_1_wrapper.v"
set_property top "design_1_wrapper" [current_fileset]

exit



