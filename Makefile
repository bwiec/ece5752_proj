VIVADO_PRJ := build/proj/proj.xpr
BIT = build/proj/proj.runs/impl_1/design_1_wrapper.pdi
HW_DEPS := tcl/bd.tcl \
		   rtl/ \
		   xdc/
TEST_VECTORS := ar0231_macbeth_demosaic_only_small.dat \
			   ar0231_rgb_cereal_small.dat

SIM_RESULTS := ar0231_macbeth_demosaic_only_small.result \
			   ar0231_rgb_cereal_small.result

.SILENT:
.PHONY: all testvector project sim display_results bitstream clean

all: display_results bitstream

testvector: $(TEST_VECTORS)
test/%.dat: test/%.png
	python3 generate_testvector.py $@

project: $(VIVADO_PRJ)
$(VIVADO_PRJ): $(HW_DEPS)
	rm -rf build; # If one of those files/directories changes, we need to re-build the vivado project since build_hardware.tcl isn't re-entrant
	mkdir -p build
	vivado -mode batch -notrace -source tcl/build_hardware.tcl

sim: $(SIM_RESULTS)
$(SIM_RESULTS): $(VIVADO_PRJ) $(TEST_VECTORS)
	vivado -mode batch -notrace -source tcl/run_sim.tcl

display_results: $(SIM_RESULTS)
$(SIM_RESULTS):
	python3 display_testvector.py $*

bitstream: $(BIT)
$(BIT): $(VIVADO_PRJ)
	vivado -mode batch -notrace -source tcl/build_bitstream.tcl

clean:
	rm -rf vivado* build .Xil *dynamic* *.log *.xpe
	rm -f test/*.result *.dat
