`include "memory.v"
module mtb;
parameter SIZE=256;
parameter WIDTH=16;
parameter DEPTH=64;
parameter ADDR_WIDTH=$clog2(DEPTH);
reg clk_i,rst_i,valid_i,wr_rd_i;
reg [ADDR_WIDTH-1:0]addr_i;
reg [WIDTH-1:0]wdata_i;
wire [WIDTH-1:0]rdata_o;
wire ready_o;
reg[WIDTH-1:0] mem[DEPTH-1:0];
integer i;
reg [8*50:1]testnames;
memory #(.SIZE(SIZE),.WIDTH(WIDTH),.DEPTH(DEPTH),.ADDR_WIDTH(ADDR_WIDTH)) dut(clk_i,rst_i,valid_i,wr_rd_i,addr_i,wdata_i,rdata_o,ready_o);
initial begin clk_i=0; 
forever #1 clk_i=~clk_i; end
initial begin 
$value$plusargs("testnames=%s",testnames); rst_i=1; rst_inputs(); #3 rst_i=0;
//writing test casses !...
case(testnames)
"test_wr_rd_one_logic" : begin
 write_memory(5'h5,1);
 read_memory(5'h15,1); end
"test_quarter_basics" : begin
 // first quarter 0 to 15
 write_memory(0,DEPTH/4);
 read_memory(0,DEPTH/4); end
 /*  //second quarter 16 to 31
 write_memory(DEPTH/4,DEPTH/4);
 read_memory(DEPTH/4,DEPTH/4);
 // third quarter 32 to 47
  write_memory(DEPTH/2,DEPTH/4);
 read_memory(DEPTH/2,DEPTH/4);
 // last quarter 47 to 63
  write_memory((3*DEPTH/4),DEPTH/4);
 read_memory((3*DEPTH/4),DEPTH/4);*/
 "test_wr_rd_all_locs" : begin
  write_memory(0,DEPTH);
 read_memory(0,DEPTH);  end
 "test_fd_wr_fd_rd" : begin
 write_memory(0,DEPTH);
 read_memory(0,DEPTH); end
 "test_fd_wr_bd_rd" : begin
 write_memory(0,DEPTH);
 read_memory_bd(0,DEPTH); end
 "test_bd_wr_bd_rd" : begin
 write_memory_bd(0,DEPTH);
 read_memory_bd(0,DEPTH); end
 "test_bd_wr_fd_rd" : begin
 write_memory_bd(0,DEPTH);
 read_memory(0,DEPTH); end
 endcase
end
task rst_inputs(); begin addr_i=0;wr_rd_i=0;wdata_i=0;valid_i=0;  end endtask
// task to write data to memory !...
task write_memory(input [ADDR_WIDTH-1:0]s_loc,input [ADDR_WIDTH:0]no_of_loc); begin
for(i=s_loc;i<=s_loc+no_of_loc-1;i=i+1) begin @(posedge clk_i); addr_i=i;wr_rd_i=1;wdata_i=$random;valid_i=1;
wait(ready_o==1); end @(posedge clk_i); rst_inputs(); end endtask
// task to read data from memory !...
task read_memory(input [ADDR_WIDTH-1:0]s_loc,input [ADDR_WIDTH:0]no_of_loc); begin
for(i=s_loc;i<=s_loc+no_of_loc-1;i=i+1) begin @(posedge clk_i); addr_i=i;wr_rd_i=0;valid_i=1;
wait(ready_o==1); end @(posedge clk_i); rst_inputs(); end endtask

task read_memory_bd(input [ADDR_WIDTH-1:0]s_loc,input [ADDR_WIDTH:0]no_of_loc);
$writememh("img.txt",dut.mem);
endtask

task write_memory_bd(input [ADDR_WIDTH-1:0]s_loc,input [ADDR_WIDTH:0]no_of_loc);
$readmemh("img1.txt",dut.mem); 
endtask

initial begin #500; $finish(); end 
endmodule
