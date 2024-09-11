//`timescale 1ns/1ps
`include "spi.v"
module tb;

parameter MAX_TXS=8;
parameter WIDTH=8;

parameter S_IDLE				=5'b0_0001;
parameter S_ADDR				=5'b0_0010;
parameter S_IDLE_BW_ADDR_DATA	=5'b0_0100;
parameter S_DATA				=5'b0_1000;
parameter S_TX_PENDING			=5'b1_0000;

reg pclk_i;
reg prst_i;
reg penable_i;
reg [WIDTH-1:0]paddr_i;
reg [WIDTH-1:0]pwdata_i;
reg pwrite_i;
reg miso_i;
reg sclk_ref_i;

wire [WIDTH-1:0]prdata_o;
wire pready_o;
wire sclk_o;
wire mosi_o;
wire [3:0] cs_o;//depends on number of slaves, if 4 slaves then 3:0

integer i;

spi dut(
			.pclk_i(pclk_i),
			.prst_i(prst_i),
			.penable_i(penable_i),
			.paddr_i(paddr_i),
			.pwdata_i(pwdata_i),
			.prdata_o(prdata_o),
			.pready_o(pready_o),
			.pwrite_i(pwrite_i),
			.sclk_ref_i(sclk_ref_i),
			.sclk_o(sclk_o),
			.mosi_o(mosi_o),
			.miso_i(miso_i),
			.cs_o(cs_o)
		);

//generating pclk

always begin
	pclk_i=0; #5;
	pclk_i=1; #5;
end

//generating sclk_ref_i
always begin
	sclk_ref_i=0; #2;
	sclk_ref_i=1; #2;
end

task reset();
begin
	penable_i=0;
	paddr_i=0;
	pwdata_i=0;
	pwrite_i=0;
	miso_i=1;
	sclk_ref_i=0;
end
endtask

task write(input reg [7:0]addr, input reg [7:0]data);
begin
	@(posedge pclk_i);	
	pwrite_i=1;
	paddr_i=addr;
	pwdata_i=data;
	penable_i=1;
	wait (pready_o==1);
	@(posedge pclk_i);
	pwrite_i=0;
	paddr_i=0;
	pwdata_i=0;
	penable_i=0;
end
endtask
initial begin
	prst_i=1;
	reset();
	repeat(2)@(posedge pclk_i);
	prst_i=0;

	//processor
	//programming registers
	
	//addr_regA
	for(i=0;i<MAX_TXS;i=i+1)begin
		write(i,i+8'h53);//0-d3//1-d4//2-d5//3-d6
	end
	
	//data_regA
	for(i=0;i<MAX_TXS;i=i+1)begin
		write(i+8'h10,i+8'h12);//10-12//11-13//12-14
	end

	//Control Register
	write(8'h20,{8'b0_000_111_1});//0_000_000_1
	#1000;
	
	//addr_regA
	for(i=0;i<MAX_TXS;i=i+1)begin
		write(i,i+8'hd1);
	end
	write(8'h20,{8'h0f});
	#1000;

	
	//Ending Simulation
//	#500;
	$finish;
end
endmodule
