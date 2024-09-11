`include "ic.v"
module tb;

	parameter NUM_INTR=16;
	parameter WIDTH=$clog2(NUM_INTR);

	parameter S_NO_INTERRUPT = 3'b001;
	parameter S_ACTIVE_INTERRUPT = 3'b010;
	parameter S_INTERRUPT_SERVICED = 3'b100;


	//APB signals
	reg pclk_i,prst_i,penable_i,pwrite_i;
	reg [WIDTH-1:0]paddr_i,pwdata_i;
	wire pready_o;
	wire [WIDTH-1:0] prdata_o;
	
	//Interrupt controller signals
	reg [NUM_INTR-1:0]interrupt_active_i; 
	reg interrupt_serviced_i;
	wire interrupt_valid_o;
	wire [WIDTH-1:0] interrupt_to_be_serviced_o;

		reg [WIDTH-1:0] priority_reg[NUM_INTR-1:0];
       integer  priority_array[NUM_INTR-1:0];
	integer i;

	interrupt_controller dut(.*);
	always #5 pclk_i=~pclk_i;

	initial begin
		pclk_i=0;
		prst_i=1;
		reset();
		repeat(2)@(posedge pclk_i);
		prst_i=0;

           random();
		  for(i=0;i<NUM_INTR;i=i+1)begin
		   
		  			$display("intr_number=%0d, priority_array=%0d",i, priority_array[i]
					);
					write(i,priority_array[i]);
				end

			interrupt_active_i=$random;
			#500;
		$finish;
	end

	//processor MOdelling
	always@(posedge pclk_i)begin
		if(interrupt_to_be_serviced_o!=0)begin
			#20;
			interrupt_active_i[interrupt_to_be_serviced_o]=0;
			interrupt_serviced_i=1;
			//@(posedge pclk_i);
			#10;
			interrupt_serviced_i=0;
		end
	end

	task reset();
	begin
		penable_i=0;pwrite_i=0;
		paddr_i=0;pwdata_i=0;
		interrupt_active_i=0; 
		interrupt_serviced_i=0;
		for(i=0;i<NUM_INTR;i=i+1) priority_reg[i]=0;
	end
	endtask

	task write(input [WIDTH-1:0] addr, input [WIDTH-1:0] priority_data);
	begin
		@(posedge pclk_i);
		pwrite_i=1;
		paddr_i=addr;
		pwdata_i=priority_data;
		penable_i=1;
		wait(pready_o==1);
		@(posedge pclk_i);
		pwrite_i=0;
		paddr_i=0;
		pwdata_i=0;
		penable_i=0;
	end
	endtask

task random();
reg flag;
integer p,q;
integer value;
begin
//initial begin
	for(p=0;p<NUM_INTR;)begin
		flag=1;//no value matched
		value=$urandom_range(0,15);
		for(q=0;q<p;q=q+1)begin
			if(priority_array[q]==value)begin
				flag=0;
				q=p;//value matched
			end
			else flag=1;
		end
		if(flag==1)begin
			priority_array[p]=value;
			p=p+1;
		end
	end
end
endtask


endmodule		
