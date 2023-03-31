BIT = build/proj/proj.runs/impl_1/design_1_wrapper.pdi
HW_DEPS := tcl/bd.tcl \
		   rtl/ \
		   xdc/

.SILENT:
.PHONY: project bitstream clean

project: build/proj/proj.xpr
build/proj/proj.xpr: $(HW_DEPS)
	rm -rf build; # If one of those files/directories changes, we need to re-build the vivado project since build_hardware.tcl isn't re-entrant
	mkdir -p build
	vivado -mode batch -notrace -source tcl/build_hardware.tcl

bitstream: $(BIT)
$(BIT): build/proj/proj.xpr
	vivado -mode batch -notrace -source tcl/build_bitstream.tcl

clean:
	rm -rf vivado* build .Xil *dynamic* *.log *.xpe
