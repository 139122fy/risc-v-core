# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7s15ftgb196-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir E:/riscV/riscV.cache/wt [current_project]
set_property parent.project_path E:/riscV/riscV.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo e:/riscV/riscV.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib {
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/defines.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/clint.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/csr_reg.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/ctrl.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/div.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/ex.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/perips/gpio.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/id.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/id_ex.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/if_id.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/debug/jtag_dm.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/debug/jtag_driver.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/debug/jtag_top.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/pc_reg.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/perips/ram.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/regs.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/rib.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/perips/rom.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/core/tinyriscv.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/perips/uart.v
  E:/riscV/riscV.srcs/sources_1/imports/rtl/soc/tinyriscv_soc_top.v
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc E:/riscV/riscV.srcs/constrs_1/new/tinyriscv.xdc
set_property used_in_implementation false [get_files E:/riscV/riscV.srcs/constrs_1/new/tinyriscv.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top tinyriscv_soc_top -part xc7s15ftgb196-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef tinyriscv_soc_top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file tinyriscv_soc_top_utilization_synth.rpt -pb tinyriscv_soc_top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
