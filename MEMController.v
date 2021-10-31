//1. check whether memory read complete
//2. send data address to Mems
//3. check whether memory write complete
//4. finish the task

//Computing: 1 if it is in computing status, else 0 to stop the computing
//Assume we have 3 RAMs to store data
//RAM0: INPUT0, RAM1: INPUT1, RAM2:OUTPUT

//para_deg: the data path complete #para_deg tasks at once (parallelly)
//so the computation_step_counter need to +para_deg at once

//load_old_output: whether to sum up with old output

module MEMController
		#(	parameter Addr_Width = 4,
			parameter Ram_Depth = 1 << Addr_Width,
			parameter Nums_SRAM = 3,
			parameter bits_Computation = 4,
			parameter Nums_Computation = 1 << bits_Computation,
			parameter Para_Deg = 1)
		(clk, Mem_reset, Comp_reset, Computing, Mem_Clear, En_Chip_Select, En_Write, En_Read, Addr_Read, Addr_Write, test);

		input clk, Mem_reset, Comp_reset, Computing;
		output reg [Nums_SRAM - 1:0] Mem_Clear, En_Chip_Select, En_Write, En_Read;
		output reg [Nums_SRAM * Ram_Depth - 1:0] Addr_Read , Addr_Write;

		reg [bits_Computation-1:0] computation_step_counter;
		output [bits_Computation-1:0] test;

		assign test = computation_step_counter;
		
		integer Ram_Index;

		always@(posedge clk) begin
			if(Mem_reset) begin
				for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemReset
					Mem_Clear[Ram_Index] <= 0;
				end
			end
			if(Comp_reset) begin
				computation_step_counter <= 0;
			end

			if (Computing) begin
				for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemSetComputingSignals
					En_Chip_Select[Ram_Index] <= 1;
					Addr_Read[Ram_Depth * Ram_Index +: Ram_Depth] <= computation_step_counter;
				end
				En_Read[0] <= 1;
				En_Read[1] <= 1;
				En_Read[2] <= 1;

				En_Write[0] <= 0;
				En_Write[1] <= 0;
				En_Write[2] <= 1;

				Addr_Write[Ram_Depth * 0 +: Ram_Depth] <= 0;
				Addr_Write[Ram_Depth * 1 +: Ram_Depth] <= 0;
				Addr_Write[Ram_Depth * 2 +: Ram_Depth] <= computation_step_counter;

				if(computation_step_counter < Nums_Computation) begin
					computation_step_counter <= computation_step_counter + Para_Deg;
				end
				else begin
					computation_step_counter <= 0;
				end
			end
			else begin
				for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemNoOperation
					En_Chip_Select[Ram_Index] <= 0;
					En_Read[Ram_Index] <= 0;
					En_Write[Ram_Index] <= 0;
					Addr_Read[Ram_Depth * Ram_Index +: Ram_Depth] <= 0;
					Addr_Write[Ram_Depth * 0 +: Ram_Depth] <= 0;
				end
			end
		end
		
		
endmodule
