module spi(
//APB
pclk_i,prst_i,penable_i,paddr_i,pwdata_i,prdata_o,pready_o,pwrite_i,
//spi
sclk_ref_i,sclk_o,mosi_o,miso_i,cs_o
);

parameter MAX_TXS=8;
parameter WIDTH=8;

parameter S_IDLE				=5'b0_0001;
parameter S_ADDR				=5'b0_0010;
parameter S_IDLE_BW_ADDR_DATA	=5'b0_0100;
parameter S_DATA				=5'b0_1000;
parameter S_TX_PENDING			=5'b1_0000;

input pclk_i;
input prst_i;
input penable_i;
input [WIDTH-1:0]paddr_i;
input [WIDTH-1:0]pwdata_i;
input pwrite_i;
input miso_i;
input sclk_ref_i;

output reg [WIDTH-1:0]prdata_o;
output reg pready_o;
output sclk_o;
output reg mosi_o;
output reg [3:0] cs_o;//depends on number of slaves, if 4 slaves then 3:0

//registers

reg [WIDTH-1:0]addr_regA[MAX_TXS-1:0];
reg [WIDTH-1:0]data_regA[MAX_TXS-1:0];
reg [WIDTH-1:0]ctrl_regA;

//Registers for State machine

reg [4:0]state,next_state;

reg sclk_running_f;
reg [3:0]num_tx_pending;//[3:1]
reg [3:0]current_tx_index;//[6:4]
reg [WIDTH-1:0]data_rx;
reg [WIDTH-1:0]data_tx;
reg [WIDTH-1:0]addr_tx;

integer i,count;


//Programming spi Registers
always@(posedge pclk_i)begin
	if(prst_i==1)begin
		prdata_o=0;
		pready_o=0;
		mosi_o=1;
		cs_o=3'b001;
		for(i=0;i<MAX_TXS;i=i+1)begin
			addr_regA[i]=0;
			data_regA[i]=0;
		end
		ctrl_regA=0;
		state=S_IDLE;
		next_state=S_IDLE;
		num_tx_pending=0;
		current_tx_index=0;
		data_rx=0;
		data_tx=0;
		addr_tx=0;
		count=0;
		sclk_running_f=0;
	end
	else begin
		if(penable_i==1)begin
			pready_o=1;
			if(pwrite_i==1)begin
				if(paddr_i>=8'h00 && paddr_i<=8'h07)begin
					addr_regA[paddr_i]=pwdata_i;		
				end
				if(paddr_i>=8'h10 && paddr_i<=8'h17)begin
					data_regA[paddr_i-8'h10]=pwdata_i;		
				end
				if(paddr_i==8'h20)begin
					ctrl_regA=pwdata_i;
				end
			end
			else begin
				if(paddr_i>=8'h0 && paddr_i<=8'h7)begin
					prdata_o=addr_regA[paddr_i];		
				end
				if(paddr_i>=8'h10 && paddr_i<=8'h17)begin
					prdata_o=data_regA[paddr_i-8'h10];		
				end
				if(paddr_i==8'h20)begin
					prdata_o=ctrl_regA;
				end
			end
		end
	end
end

//Generating sclk

assign sclk_o = sclk_running_f ? (sclk_ref_i) : (1'b1);
//SPI State machine
always@(posedge sclk_ref_i)begin
	if(prst_i!=1)begin
		case(state)
			S_IDLE: begin
					sclk_running_f=0;
					mosi_o=1;
					if(ctrl_regA[0]==1)begin
						count=0;
						num_tx_pending=ctrl_regA[3:1]+1;
						current_tx_index=ctrl_regA[6:4];
						addr_tx=addr_regA[current_tx_index];
						data_tx=data_regA[current_tx_index];
						next_state=S_ADDR;
					end
			end
			S_ADDR: begin
					sclk_running_f=1;
					mosi_o=addr_tx[count];
					count=count+1;
					if(count==8)begin
						count=0;
						next_state=S_IDLE_BW_ADDR_DATA;
					end
			end
			S_IDLE_BW_ADDR_DATA: begin
					sclk_running_f=0;
					mosi_o=1;
					count=count+1;
					if(count==4)begin
						count=0;
						next_state=S_DATA;
					end
			end
			S_DATA: begin
					sclk_running_f=1;
					if(addr_tx[WIDTH-1]==1)begin
						mosi_o=data_tx[count];
						count=count+1;
					end
					else begin
						data_rx[count]=miso_i;
						count=count+1;
					end
					if(count==8)begin
						current_tx_index=current_tx_index+1;//000-----111
						num_tx_pending=num_tx_pending-1;//111-----000
						if(num_tx_pending==0)begin
							count=0;
							ctrl_regA[WIDTH-1]=1;
							ctrl_regA[0]=0;
							next_state=S_IDLE;
						end
						else begin
							count=0;
							next_state=S_TX_PENDING;
						end
					end
			end
			S_TX_PENDING: begin
					sclk_running_f=0;
					mosi_o=1;
					count=count+1;
					if(count==4)begin
						count=0;
						addr_tx=addr_regA[current_tx_index];
						data_tx=data_regA[current_tx_index];
						next_state=S_ADDR;
					end
			end
		endcase
	end
end
//updating states in state machine
always@(next_state)begin
	state=next_state;
end
endmodule
