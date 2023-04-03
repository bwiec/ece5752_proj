SIM_TIME_US := 10
START_GUI ?= 1

PROJ := build/proj/proj.xpr
BIT = build/proj/proj.runs/impl_1/design_1_wrapper.pdi
HW_DEPS := tcl/bd.tcl \
		  		 rtl/ \
		  		 xdc/
TEST_VECTORS := test/ar0231_macbeth_demosaic_only_small.dat \
			  				test/ar0231_rgb_cereal_small.dat

SIM_RESULTS := build/proj/proj.sim/ar0231_macbeth_demosaic_only_small.result \
			   			 build/proj/proj.sim/ar0231_rgb_cereal_small.result

.SILENT:
.PHONY: all testvector proj sim display_results bitstream clean
.ONESHELL:

all: display_results bitstream

testvector: $(TEST_VECTORS)
test/%.dat: test/%.png
	python3 test/generate_testvector.py $^

proj: $(PROJ)
$(PROJ): $(HW_DEPS)
	rm -rf build; # If one of those files/directories changes, we need to re-build the vivado project since build_hardware.tcl isn't re-entrant
	mkdir -p build
	vivado -mode batch -notrace -source tcl/build_hardware.tcl

sim: $(SIM_RESULTS) 
$(subst build/proj/proj.sim,%,$(SIM_RESULTS)): tcl/run_sim.tcl $(TEST_VECTORS) $(PROJ)
	cd build
	vivado -mode tcl -notrace -source "../$<" -tclargs $(SIM_TIME_US) $(START_GUI)

display_results: $(SIM_RESULTS)
	python3 display_testvector.py $^

synth: tcl/run_synth.tcl $(PROJ)
timing_report: tcl/generate_timing.tcl $(PROJ)
	vivado -mode tcl -notrace -source "../$<"

open_proj_gui: $(PROJ)
	vivado $<

publish: clean
	cd ..
	zip -r $(TIME)_ece5752_proj.zip ece5752_proj

clean:
	rm -rf .Xil Packages
	rm -f *.jou *.log *.str	
	rm -rf build
	rm -f test/*.dat
