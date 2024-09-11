`include "Async_fifo.v"
module async_fifo_tb;
// parameters decleration
parameter WIDTH=8,DEPTH=16,PTR_WIDTH=$clog2(DEPTH);
// port's instantiation
// inputs
reg wr_clk,rd_clk,rst,wr_en,rd_en;
reg [WIDTH-1:0]wdata;
// outputs
wire [WIDTH-1:0]rdata;
wire full,empty,wr_err,rd_err;
integer i;
// dut instantiation
async_fifo async_fifo_tb(wr_clk,rd_clk,rst,wdata,rdata,wr_en,rd_en,full,empty,wr_err,rd_err);
// generate two clocks 
always #5 wr_clk=~wr_clk;
always #10 rd_clk=~rd_clk;
initial begin wr_clk=0;rd_clk=0;rst=1;wr_en=0;rd_en=0;wdata=0;
 #20; rst=0; for(i=0;i<DEPTH;i=i+1) begin
                @(posedge wr_clk);
				wr_en=1;
				wdata=$random;
			 end
			    @(posedge wr_clk);
				   wr_en=0;
				   wdata=0;
             for(i=0;i<DEPTH;i=i+1) begin
                @(posedge rd_clk);
				rd_en=1;
			end
			@(posedge rd_clk);
			rd_en=0;
			end
initial begin #1000; $finish(); end
endmodule

