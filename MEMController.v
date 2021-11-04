module MEMController
		#(	
			parameter Addr_Width = 4,
			parameter Ram_Depth = 1 << Addr_Width,
			parameter Nums_SRAM_In = 2,
			parameter Nums_SRAM_Out = 1,
			parameter Nums_SRAM = Nums_SRAM_In + Nums_SRAM_Out,
			parameter Nums_Data_in_bits = 4,
			parameter Nums_Data = 1 << Nums_Data_in_bits,
			parameter Nums_Pipeline_Stages = 4,
			parameter Pipeline_Tail = Nums_Pipeline_Stages - 1,
			parameter Total_Computation_Steps = Nums_Data + Pipeline_Tail,
			parameter Para_Deg = 1
		)
		(clk, Mem_reset, Comp_reset, Mem_Index_reset, load_from_file, Computing, write_to_file, loading_signal, computing_signal, write_to_file_signal,
		Mem_Clear, En_Chip_Select, En_Write, En_Read, Addr_Read, Addr_Write, 
		test, mem_index_test);

		input clk, Mem_reset, Comp_reset, Mem_Index_reset, load_from_file, Computing, write_to_file;
		output reg [Nums_SRAM - 1:0] Mem_Clear, En_Chip_Select, En_Write, En_Read;
		output reg [Nums_SRAM * Addr_Width - 1:0] Addr_Read , Addr_Write;

		reg [Nums_Data_in_bits:0] computation_step_counter;
		output reg loading_signal = 0, computing_signal = 0, write_to_file_signal = 0;
		output [Nums_Data_in_bits:0] test;
		reg [Addr_Width:0] mem_index_counter; //to record the accessed memory index

		output [Addr_Width:0] mem_index_test;
		assign mem_index_test = mem_index_counter;

		assign test = computation_step_counter;
		integer Ram_Index;
		integer Addr_Index;

		//reset memory
		always@(posedge clk) begin
			if(Mem_reset) begin
				for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemReset
					Mem_Clear[Ram_Index] <= 0;
				end
			end
		end

		//signal setting(loading or computing or writing)
		always@(posedge clk) begin
			if(load_from_file) begin
				loading_signal <= 1;
			end
			else if (loading_signal)  begin
				if (mem_index_counter < Ram_Depth) begin
					loading_signal <= loading_signal;
				end
				else begin
					loading_signal <= 0;
				end
			end
			else begin
				loading_signal <= 0;
			end

			if(Computing) begin
				computing_signal <= 1;
			end
			else if (computing_signal) begin
				if (computation_step_counter < Total_Computation_Steps) begin
					computing_signal <= computing_signal;
				end
				else begin
					computing_signal <= 0;
				end
			end
			else begin
				computing_signal <= computing_signal;
			end

			if (write_to_file) begin
				write_to_file_signal <= 1;	
			end
			else if (write_to_file_signal) begin
				if(mem_index_counter < Ram_Depth + 1) begin
					write_to_file_signal <= write_to_file_signal;
				end
				else begin
					write_to_file_signal <= 0;
				end
			end
			else begin
				write_to_file_signal <= write_to_file_signal;
			end

		end
		

		//set read/write memory index
		always@(posedge clk) begin
			if(Mem_Index_reset) begin
				mem_index_counter <= 0;
			end
			else if(loading_signal) begin
				if (mem_index_counter < Ram_Depth) begin
					mem_index_counter <= mem_index_counter + Para_Deg; 
				end
				else begin
					mem_index_counter <= mem_index_counter;
				end
			end
			else if(write_to_file_signal) begin
				if (mem_index_counter < Ram_Depth + 1) begin
					mem_index_counter <= mem_index_counter + Para_Deg;
				end
				else begin
					mem_index_counter <= mem_index_counter;
				end
			end
			else begin
				mem_index_counter <= mem_index_counter;
			end			
		end
		
		//set computation steps
		always@(posedge clk) begin
			if(Comp_reset) begin
				computation_step_counter <= 0;
			end
			else if(computing_signal) begin
				if (computation_step_counter < Total_Computation_Steps) begin
					computation_step_counter <= computation_step_counter + Para_Deg;
				end
				else begin
					computation_step_counter <= computation_step_counter;
				end
			end
		end

		//set memory signals
		always @(posedge clk) begin

			if(loading_signal) begin
				if (mem_index_counter < Ram_Depth) begin
					for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemSetLoadingSignals
						En_Chip_Select[Ram_Index] <= 1;
						En_Read[Ram_Index] <= 1;
						En_Write[Ram_Index] <= 1;
						Addr_Write[Ram_Index * Addr_Width +: Addr_Width] <= mem_index_counter;
						Addr_Read[Ram_Index * Addr_Width +: Addr_Width] <= mem_index_counter - 2;
					end
				end
				else begin
					for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemSetNotLoadingSignals
						En_Chip_Select[Ram_Index] <= 0;
						En_Read[Ram_Index] <= 0;
						En_Write[Ram_Index] <= 0;
						Addr_Write[Ram_Index * Addr_Width +: Addr_Width] <= 0;
						Addr_Read[Ram_Index * Addr_Width +: Addr_Width] <= 0;
					end
				end				
			end

			else if(write_to_file_signal) begin
				if (mem_index_counter < Ram_Depth + 1) begin
					for(Ram_Index = Nums_SRAM_In; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemSetWritingSignals
						En_Chip_Select[Ram_Index] <= 1;
						En_Read[Ram_Index] <= 1;
						En_Write[Ram_Index] <= 0;
						Addr_Write[Ram_Index * Addr_Width +: Addr_Width] <= 0;
						Addr_Read[Ram_Index * Addr_Width +: Addr_Width] <= mem_index_counter;
					end
				end
				else begin
					for(Ram_Index = Nums_SRAM_In; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemSetNotWritingSignals
						En_Chip_Select[Ram_Index] <= 0;
						En_Read[Ram_Index] <= 0;
						En_Write[Ram_Index] <= 0;
						Addr_Write[Ram_Index * Addr_Width +: Addr_Width] <= 0;
						Addr_Read[Ram_Index * Addr_Width +: Addr_Width] <= 0;
					end
				end				
			end

			else if(computing_signal) begin
				if(computation_step_counter < Total_Computation_Steps) begin
					for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemSetComputingSignalsAllSRAM
						En_Chip_Select[Ram_Index] <= 1;
						if(computation_step_counter < Total_Computation_Steps - Pipeline_Tail) begin
							En_Read[Ram_Index] <= 1;
							Addr_Read[Ram_Index * Addr_Width +: Addr_Width] <= computation_step_counter;
						end
						else begin
							En_Read <= 0;
							Addr_Read <= 0;
						end
					end
					for(Ram_Index = 0; Ram_Index < Nums_SRAM_In; Ram_Index = Ram_Index + 1) begin: MemSetComputingSignalsInputSRAM
						En_Write[Ram_Index] <= 0;
						Addr_Write[Ram_Index * Addr_Width +: Addr_Width] <= 0;
					end
					for(Ram_Index = Nums_SRAM_In; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: MemSetComputingSignalsOutputSRAM
						if(computation_step_counter > 1 && computation_step_counter < Total_Computation_Steps - 1) begin
							En_Write[Ram_Index] <= 1;
							Addr_Write[Ram_Index * Addr_Width +: Addr_Width] <= computation_step_counter - 2;
						end
						else begin
							En_Write[Ram_Index] <= 0;
							Addr_Write[Ram_Index * Addr_Width +: Addr_Width] <= 0;						
						end
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

			else begin
				En_Chip_Select <= 0;
				En_Read <= 0;
				En_Write <= 0;
				Addr_Read <= 0;
				Addr_Write <= 0;
			end
		
		end
		
endmodule