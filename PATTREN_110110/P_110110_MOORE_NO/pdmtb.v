`include "pdm.v"
module pdmtb;
reg clk_i,rst_i,data_i,valid_i;
wire pd_o;
integer count;
//design instantiation ...
pdm dut(clk_i,rst_i,data_i,valid_i,pd_o);
//clock generation ...
initial begin 
clk_i=0; 
forever #5 clk_i=~clk_i; 
end
initial begin 
rst_i=1;
data_i=0;
valid_i=0;
count=0; 
#20;
rst_i=0;
repeat(200) begin
@(posedge clk_i);
data_i=$random;
valid_i=1'b1;
end
@(posedge clk_i);
data_i=1'b0;
valid_i=1'b0;
#200;
$finish();
end
always @(posedge pd_o) begin
count=count+1;
#1;
$display("Pattern Count=%0d",count);
end
endmodule

