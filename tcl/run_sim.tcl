set SIM_TIME_US [lindex $argv 0]
set START_GUI [lindex $argv 1]

open_project ../build/proj/proj.xpr
launch_simulation
open_wave_config ../wcfg/tb_behav.wcfg
restart

puts "Running simulation for ${SIM_TIME_US}"
run ${SIM_TIME_US} us

if { ${START_GUI} == 1 } {
  start_gui
}