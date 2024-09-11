vlib work
vlog memtb.v
vsim memorytb +testnames=test_wr_rd_all_locs
add wave /memorytb/*
run -all
