`include "pdm.v"
`timescale 1ns/1ns
module pdmtb;
reg clk_i,rst_i,data_i,valid_i;
wire pd_o;
integer count;
//design instantiation ...
pdm dut(clk_i,rst_i,data_i,valid_i,pd_o);
//clock generation ...
initial begin 
clk_i=0; 
forever #2 clk_i=~clk_i; 
end
initial begin 
rst_i=1'b1;
data_i=1'b1;
valid_i=1'b0;
count=0; 
#4;
rst_i=0;
valid_i=1'b1;
@(posedge clk_i);
data_i=1;
@(posedge clk_i);
data_i=0;
@(posedge clk_i);
data_i=1;
@(posedge clk_i);
data_i=1;
@(posedge clk_i);
data_i=0;
@(posedge clk_i);
data_i=1;
@(posedge clk_i);
data_i=1;
@(posedge clk_i);
data_i=0;
@(posedge clk_i);
data_i=1;
@(posedge clk_i);
data_i=1;
@(posedge clk_i);
data_i=0;
repeat(3) @(posedge clk_i);
data_i=1'b0; 
valid_i=1'b0; 
$display("Pattern Count=%0d",count);
#20; 
$finish();
end
always @(posedge pd_o) 
count=count+1;
endmodule

