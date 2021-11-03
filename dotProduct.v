/*
Notes:
1. Parallel Function is not verified
2. Write Out is not verified

*/
/*
**parameters**

Addr_Width:			Address Width of Memories(SRAMs)
Ram_Depth:			Depth of Memories(SRAMs)
Nums_SRAM_In:		Number of SRAM to store input data
Nums_SRAM_Out:		Number of SRAM to store output data
Nums_SRAM:			Nums_SRAM_In + Nums_SRAM_Out
bits_Computation:	to record total computational steps to complete the dotproduct
Nums_Computation:	total computational steps to complete the dotproduct
Para_Deg:			parallelly compute #Para_deg products at once
Data_Width_In:		Data Width for input data
Data_Width_Out:	Data Width for output data

**inputs**

clk: 					clock signal
Mem_reset:			if 1 then clear the memory 
Comp_reset:			if 1 then clear the computational steps counter
Computing:			if 1 then do compute(dotproduct)
PE_reset:			if 1 then reset the PEGroups 
load_old_output:	if 1 then sum up multiplication result with old output, if 0 then directlly write multiplication result to the output SRAM

**outputs**

result:				dotProduct result at each state
state:				the counter to record the computational steps

*/
module dotProduct
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
			parameter Para_Deg = 1,
			parameter Data_Width_In = 8,
			parameter Data_Width_Out = 16
		)
		(clk, Mem_reset, Comp_reset, Mem_Index_reset, Computing,
		PE_reset, load_old_output, load_from_file,
		input_data_from_file, output_data_from_file,
		result, state,
		test_r, test_w, test_data); 
				
		input clk, Mem_reset, Comp_reset, Mem_Index_reset, Computing;
		input PE_reset, load_old_output, load_from_file;
		input [Nums_SRAM_In * Para_Deg * Data_Width_In - 1:0] input_data_from_file;
		input [Nums_SRAM_Out * Para_Deg * Data_Width_Out - 1:0] output_data_from_file;
		
		output [Para_Deg * Data_Width_Out - 1:0] result;
		output [Nums_Data_in_bits:0] state;
		
		//tests
		output [Nums_SRAM * Addr_Width - 1:0] test_r , test_w;
		output [Nums_SRAM_In * Para_Deg * Data_Width_In - 1:0] test_data;
		//

		wire [Nums_SRAM - 1:0] memclear, cs, en_w, en_r;
		wire [Nums_SRAM * Addr_Width - 1:0] read_addr, write_addr;

		wire [Para_Deg * Data_Width_In - 1:0] data_in [0:Nums_SRAM_In-1];
		wire [Para_Deg * Data_Width_Out - 1:0] old_output;
		wire [Para_Deg * Data_Width_Out - 1:0] data_out [0:Nums_SRAM_Out-1];
		wire [Para_Deg * Data_Width_In - 1:0] write_in_data [0:Nums_SRAM_In-1];
		wire [Para_Deg * Data_Width_Out - 1:0] write_out_data [0:Nums_SRAM_Out-1];

		MEMController #(.Addr_Width(Addr_Width), .Ram_Depth(Ram_Depth), .Nums_SRAM_In(Nums_SRAM_In), .Nums_SRAM_Out(Nums_SRAM_Out), .Nums_SRAM(Nums_SRAM),
		.Nums_Data_in_bits(Nums_Data_in_bits), .Nums_Data(Nums_Data), .Nums_Pipeline_Stages(Nums_Pipeline_Stages), .Pipeline_Tail(Pipeline_Tail),
		.Total_Computation_Steps(Total_Computation_Steps), .Para_Deg(Para_Deg))
		memcontroller (.clk(clk), .Mem_reset(Mem_reset), .Comp_reset(Comp_reset), .Mem_Index_reset(Mem_Index_reset), .load_from_file(load_from_file), .Computing(Computing), 
		.Mem_Clear(memclear), .En_Chip_Select(cs), .En_Write(en_w), .En_Read(en_r), .Addr_Read(read_addr), .Addr_Write(write_addr), .test(state));

		
		genvar SRAM_Index;
		generate
			for(SRAM_Index = 0; SRAM_Index < Nums_SRAM_In; SRAM_Index = SRAM_Index + 1) begin: SRAMsINs
				Dual_SRAM #(.Data_Width(Data_Width_In), .Addr_Width(Addr_Width), .Ram_Depth(Ram_Depth), .Para_Deg(Para_Deg))
				srams_inputs (.clk(clk), .Mem_Clear(memclear[SRAM_Index]), .Chip_Select(cs[SRAM_Index]), .En_Write(en_w[SRAM_Index]),
				.En_Read(en_r[SRAM_Index]), .Addr_Write(write_addr[Addr_Width * SRAM_Index +: Addr_Width]), 
				.Addr_Read(read_addr[Addr_Width * SRAM_Index +: Addr_Width]), .Write_Data(write_in_data[SRAM_Index]), .Read_Data(data_in[SRAM_Index]));
				assign write_in_data[SRAM_Index] = load_from_file ? input_data_from_file[SRAM_Index * Para_Deg * Data_Width_In +: Data_Width_In] : 0;

				
				assign test_r[SRAM_Index * Addr_Width +: Addr_Width] = read_addr[Addr_Width * SRAM_Index +: Addr_Width];
				assign test_w[SRAM_Index * Addr_Width +: Addr_Width] = write_addr[Addr_Width * SRAM_Index +: Addr_Width];
			end
			for(SRAM_Index = Nums_SRAM_In; SRAM_Index < Nums_SRAM; SRAM_Index = SRAM_Index + 1) begin: SRAMsOuts
				Dual_SRAM #(.Data_Width(Data_Width_Out), .Addr_Width(Addr_Width), .Ram_Depth(Ram_Depth), .Para_Deg(Para_Deg))
				srams_outputs (.clk(clk), .Mem_Clear(memclear[SRAM_Index]), .Chip_Select(cs[SRAM_Index]), .En_Write(en_w[SRAM_Index]), 
				.En_Read(en_r[SRAM_Index]), .Addr_Write(write_addr[Addr_Width * SRAM_Index +: Addr_Width]), 
				.Addr_Read(read_addr[Addr_Width * SRAM_Index +: Addr_Width]), .Write_Data(write_out_data[SRAM_Index-Nums_SRAM_In]), .Read_Data(old_output));
				assign write_out_data[SRAM_Index-Nums_SRAM_In] = load_from_file ? 
						output_data_from_file[(SRAM_Index-Nums_SRAM_In) * Para_Deg * Data_Width_Out +: Data_Width_Out] : data_out[SRAM_Index-Nums_SRAM_In];

				assign test_r[(SRAM_Index) * Addr_Width +: Addr_Width] = read_addr[Addr_Width * SRAM_Index +: Addr_Width];
				assign test_w[(SRAM_Index) * Addr_Width +: Addr_Width] = write_addr[Addr_Width * SRAM_Index +: Addr_Width];
			end
		endgenerate

		assign result = data_out[0];
		
		//test
		/*
		genvar i;
		generate
			for(i = 0; i < Nums_SRAM_In; i = i + 1) begin: test
				assign test_data[i * Para_Deg * Data_Width_In +: Data_Width_In] = data_in[i];
			end
		endgenerate
		*/
		assign test_data[15:0] = data_in[0];
		assign test_data[31:16] = data_in[1];		

		PEGroup #(.Data_Width(Data_Width_In), .Para_Deg(Para_Deg))
		pegroups (.clk(clk), .reset(PE_reset), .load_old_output(load_old_output), .data0(data_in[0]), .data1(data_in[1]), .result(data_out[0]), .old_output(old_output));
		
endmodule
