vlib work
vlog memorytb.v
vsim mtb +testnames=test_bd_wr_bd_rd
add wave -position insertpoint sim:/mtb/dut/*
run -all
