module MEMController
		#(	parameter Addr_Width = 4,
			parameter Ram_Depth = 1 << Addr_Width,
			parameter Nums_SRAM = 3,
			parameter bits_Computation = 4,
			parameter Nums_Computation = 1 << bits_Computation,
			parameter Para_Deg = 2)
		(clk, Mem_reset, Comp_reset, Mem_Index_reset, Computing, load_from_file, Mem_Clear, En_Chip_Select, En_Write, En_Read, Addr_Read, Addr_Write, test);

		input clk, Mem_reset, Comp_reset, Mem_Index_reset, Computing, load_from_file;
		output reg [Nums_SRAM - 1:0] Mem_Clear, En_Chip_Select, En_Write, En_Read;
		output reg [Nums_SRAM * Addr_Width - 1:0] Addr_Read , Addr_Write;

		reg [bits_Computation-1:0] computation_step_counter;
		output [bits_Computation-1:0] test;

		reg [Addr_Width-1:0] mem_index_counter; //to record the accessed memory index

		assign test = computation_step_counter;
		
		integer Ram_Index;
		integer Addr_Index;
		
		always@(posedge clk) begin
			if(Mem_reset) begin
				for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemReset
					Mem_Clear[Ram_Index] <= 0;
				end
			end
			if(Comp_reset) begin
				computation_step_counter <= 0;
			end
			if(Mem_Index_reset) begin
				mem_index_counter <= 0;
			end
			if(load_from_file) begin
				for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemSetLoadingSignals
					En_Chip_Select[Ram_Index] <= 1;
					En_Read[Ram_Index] <= 1;
					En_Write[Ram_Index] <= 1;
					Addr_Write[Ram_Index * Addr_Width +: Addr_Width] <= mem_index_counter;
					Addr_Read[Ram_Index * Addr_Width +: Addr_Width] <= mem_index_counter;
				end
				if (mem_index_counter < Ram_Depth) begin
					mem_index_counter <= mem_index_counter + Para_Deg;
				end
				else begin
					mem_index_counter <= 0;
				end
								
			end
			else if(Computing) begin
				for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemSetComputingSignals
					En_Chip_Select[Ram_Index] <= 1;
					Addr_Read[Ram_Index * Addr_Width +: Addr_Width] <= computation_step_counter;
					En_Read[Ram_Index] <= 1;
				end

				En_Write[0] <= 0;
				En_Write[1] <= 0;
				En_Write[2] <= 1;

				Addr_Write[0 * Addr_Width +: Addr_Width] <= 0;
				Addr_Write[1 * Addr_Width +: Addr_Width] <= 0;
				Addr_Write[2 * Addr_Width +: Addr_Width] <= computation_step_counter;

				if(computation_step_counter < Nums_Computation) begin
					computation_step_counter <= computation_step_counter + Para_Deg;
				end
				else begin
					computation_step_counter <= 0;
				end
			end
			else begin
				En_Chip_Select <= 0;
				En_Read <= 0;
				En_Write <= 0;
				Addr_Read <= 0;
				Addr_Write <= 0;
			end
		end
		
		
endmodule
