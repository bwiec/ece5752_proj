open_project build/proj/proj.xpr
update_compile_order -fileset sources_1

launch_runs impl_1 -to_step write_device_image -jobs 8
wait_on_run impl_1
