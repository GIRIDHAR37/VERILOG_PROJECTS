module interrupt_controller(
	//APB ports
	pclk_i,
	prst_i,
	penable_i,
	pready_o,
	pwrite_i,
	paddr_i,
	pwdata_i,
	prdata_o,
	//IC ports
	interrupt_active_i,
	interrupt_valid_o,
	interrupt_to_be_serviced_o,
	interrupt_serviced_i);

	parameter NUM_INTR=16;
	parameter WIDTH=$clog2(NUM_INTR);

	parameter S_NO_INTERRUPT = 3'b001;
	parameter S_ACTIVE_INTERRUPT = 3'b010;
	parameter S_SERVICED_DONE = 3'b100;


	//APB signals
	input pclk_i,prst_i,penable_i,pwrite_i;
	input [WIDTH-1:0]paddr_i,pwdata_i;
	output reg pready_o;
	output reg [WIDTH-1:0] prdata_o;
	
	//Interrupt controller signals
	input [NUM_INTR-1:0]interrupt_active_i; 
	input interrupt_serviced_i;
	output reg interrupt_valid_o;
	output reg [WIDTH-1:0] interrupt_to_be_serviced_o;

	reg [WIDTH-1:0] priority_reg[NUM_INTR-1:0];
	reg [2:0]state,next_state;

	integer i;
	reg flag;
	reg [WIDTH-1:0] highest_priority_value;
	reg [WIDTH-1:0] highest_priority_peri;
	//programming the registers
	always@(posedge pclk_i)begin
		if(prst_i==1)begin
			pready_o=0;
			prdata_o=0;
			state=S_NO_INTERRUPT;
			next_state=S_NO_INTERRUPT;
			interrupt_valid_o=0;
			flag=0;
			highest_priority_value=0;
	 		highest_priority_peri=0;
			interrupt_to_be_serviced_o=0;
			for(i=0;i<NUM_INTR;i=i+1) priority_reg[i]=0;
				end
		else begin
			if(penable_i)begin
				pready_o=1;
				if(pwrite_i)begin
					priority_reg[paddr_i]=pwdata_i;
				end
				else begin
					prdata_o=priority_reg[paddr_i];
				end
			end
			else begin
				pready_o=0;
			end
		end
	end

//handling the interrupts
	always@(posedge pclk_i)begin
		if(prst_i==0)begin
			case(state)
				S_NO_INTERRUPT:begin
					if(interrupt_active_i!=0) begin
						next_state=S_ACTIVE_INTERRUPT;
						flag=1;
					end
					else next_state=S_NO_INTERRUPT;
				end

				S_ACTIVE_INTERRUPT:begin
						for (i=0;i<NUM_INTR;i=i+1) begin
							if (interrupt_active_i[i] ==1 ) begin
								if (flag) begin
									highest_priority_value=priority_reg[i];
									highest_priority_peri=i;
									flag=0;
								end
								else begin
									if (highest_priority_value<priority_reg[i]) begin
										highest_priority_value=priority_reg[i];
										highest_priority_peri=i;
									end
						    	end
							end
						end
						interrupt_valid_o=1;
						interrupt_to_be_serviced_o=highest_priority_peri;
						next_state=S_SERVICED_DONE;
						end
				S_SERVICED_DONE:begin
					if (interrupt_serviced_i)begin
						interrupt_valid_o=0;
						interrupt_to_be_serviced_o=0;
						highest_priority_value=0;
						highest_priority_peri=0;
						if (interrupt_active_i != 0) begin
							next_state=S_ACTIVE_INTERRUPT;
							flag=1;
						end
						else begin
							next_state= S_NO_INTERRUPT;
						end

					end

                end
				endcase
		end
end

always @ (next_state) state=next_state;

endmodule
