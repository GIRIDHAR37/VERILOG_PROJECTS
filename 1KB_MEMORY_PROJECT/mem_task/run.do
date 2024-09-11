vlib work
vlog memorytb.v
vsim mtb +testnames=test_wr_rd_all_locs
add wave /mtb/*
run -all
