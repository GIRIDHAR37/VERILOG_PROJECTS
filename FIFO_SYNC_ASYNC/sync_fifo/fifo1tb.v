`include "fifo1.v"
module fifo1tb;
// parameters decleration
parameter WIDTH=8,DEPTH=16,PTR_WIDTH=$clog2(DEPTH);
// port's instantiation
// inputs
reg clk,rst,wr_en,rd_en;
reg [WIDTH-1:0]wdata;
// outputs
wire [WIDTH-1:0]rdata;
wire full,empty,wr_err,rd_err;
integer i;
// dut instantiation
syncfifo fifo1tb(clk,rst,wdata,rdata,wr_en,rd_en,full,empty,wr_err,rd_err);
// generate clock 
always #5 clk=~clk;
initial begin clk=0;rst=1;wr_en=0;rd_en=0;wdata=0;
 #20; rst=0; for(i=0;i<DEPTH;i=i+1) begin
                @(posedge clk);
				wr_en=1;
				wdata=$random;
			 end
			    @(posedge clk);
				   wr_en=0;
				   wdata=0;
             for(i=0;i<DEPTH;i=i+1) begin
                @(posedge clk);
				rd_en=1;
			end
			@(posedge clk);
			rd_en=0;
			end
initial begin #1000; $finish(); end
endmodule

