`timescale 1ms/1ms
module dotProduct_tb
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
		();
		
		reg clk, Mem_reset, Comp_reset, Mem_Index_reset, Computing;
		reg PE_reset, load_old_output, load_from_file;
		reg [Nums_SRAM_In * Para_Deg * Data_Width_In - 1:0] input_data_from_file;
		reg [Nums_SRAM_Out * Para_Deg * Data_Width_Out - 1:0] output_data_from_file;
		
		wire [Para_Deg * Data_Width_Out - 1:0] result;
		wire [Nums_Data_in_bits:0] state;
		
		//tests

		wire [Nums_SRAM * Addr_Width - 1:0] test_r , test_w;
		wire [Para_Deg * Data_Width_In - 1:0] test_data;

		//
		reg [Data_Width_In-1:0] buffer_in; //to store data read from file
		reg [Data_Width_Out-1:0] buffer_out;
		
		integer file [0:Nums_SRAM];
		integer Read_Index = 0;
		integer offset_Index = 0;
		integer Ram_Index = 0;		
		
		dotProduct 
			#(.Addr_Width(Addr_Width), .Ram_Depth(Ram_Depth), .Nums_SRAM_In(Nums_SRAM_In), .Nums_SRAM_Out(Nums_SRAM_Out), .Nums_SRAM(Nums_SRAM),
			.Nums_Data_in_bits(Nums_Data_in_bits), .Nums_Data(Nums_Data), .Nums_Pipeline_Stages(Nums_Pipeline_Stages), .Pipeline_Tail(Pipeline_Tail),
			.Total_Computation_Steps(Total_Computation_Steps), .Para_Deg(Para_Deg), .Data_Width_In(Data_Width_In), .Data_Width_Out(Data_Width_Out))
			dut	(clk, Mem_reset, Comp_reset, Mem_Index_reset, Computing,
				PE_reset, load_old_output, load_from_file,
				input_data_from_file, output_data_from_file,
				result, state,
				test_r, test_w, test_data);  
			

		initial begin
			clk = 1;
			Mem_reset = 1;
			Comp_reset = 1;
			Computing = 0;
			PE_reset = 1;
			load_old_output = 0;
			load_from_file = 0;
			input_data_from_file = 0;
			output_data_from_file = 0;
			file[0] = $fopen("input0.txt","r");
			file[1] = $fopen("input1.txt","r");
			file[2] = $fopen("output.txt","r");
			file[3] = $fopen("output_test.txt","w");
			#2
			Mem_reset = 0;
			Comp_reset = 0;
			Computing = 0;
			PE_reset = 0;
			load_old_output = 0;
			load_from_file = 1;
			#2
			$display("loading...");
			for(Read_Index = 0; Read_Index < Ram_Depth; Read_Index = Read_Index + Para_Deg) begin: loadingfromfile
				#2
				$display("---Index:%0d---", Read_Index);
				for(offset_Index = 0; offset_Index < Para_Deg; offset_Index = offset_Index + 1) begin : loadingfromfileoffset
					$fscanf(file[0], "%d", buffer_in);
					input_data_from_file[0 * Para_Deg * Data_Width_In + offset_Index * Data_Width_In +: Data_Width_In] = buffer_in;
					$fscanf(file[1], "%d", buffer_in);
					input_data_from_file[1 * Para_Deg * Data_Width_In + offset_Index * Data_Width_In +: Data_Width_In] = buffer_in;
					$fscanf(file[2], "%d", buffer_out);
					output_data_from_file[0 * Para_Deg * Data_Width_Out + offset_Index * Data_Width_Out +: Data_Width_Out] = buffer_out;
				end
			end
			$fclose(file);
			#2
			load_from_file = 0;
			$display("loading complete!!");
			#4
			$display("start computing!!");
			Computing = 1;
			PE_reset = 0;
			input_data_from_file = 0;
			output_data_from_file = 0;
			#38
			Computing = 0;
			$display("write into file...");			

		end
		
		
		always #1 clk = ~clk;
		
		integer index = 0;
		always #2 begin
			$display("time= %0d, Mem_reset= %b, Comp_reset= %b, Computing= %b, PE_reset =%b, load_old_output =%b, load_from_file =%b, state =%d"
			, $time, Mem_reset, Comp_reset, Computing, PE_reset, load_old_output, load_from_file, state);
			$display("***Data_From_File***");
			for(index = 0; index < Nums_SRAM_In; index = index + 1) begin: DataFromFileInput
				for(offset_Index = 0; offset_Index < Para_Deg; offset_Index = offset_Index + 1) begin: displayInputData
					$display("input: data[%0d][%0d] =%0d, write_addr: %d, read_addr: %d, read_data: %d",
					index, offset_Index, input_data_from_file[index * Para_Deg * Data_Width_In + offset_Index * Data_Width_In +: Data_Width_In],
					 test_w[index * Addr_Width +: Addr_Width], test_r[index * Addr_Width +: Addr_Width],
					 test_data);
				end
			end
			for(index = 0; index < Nums_SRAM_Out; index = index + 1) begin: DataFromFileOutput
				for(offset_Index = 0; offset_Index < Para_Deg; offset_Index = offset_Index + 1) begin: displayOutputData
					$display("output: data[%0d][%0d] =%0d, write_addr: %d, read_addr: %d", 
					index, offset_Index, output_data_from_file[index * Para_Deg * Data_Width_Out + offset_Index * Data_Width_Out +: Data_Width_Out],
					 test_w[(Nums_SRAM_In + index) * Addr_Width +: Addr_Width], test_r[(Nums_SRAM_In + index) * Addr_Width +: Addr_Width]);
				end
			end
			for(offset_Index = 0; offset_Index < Para_Deg; offset_Index = offset_Index + 1) begin: ComputationResult
				$display("Result =%0d", result[offset_Index * Data_Width_Out +: Data_Width_Out]);
			end
		end
endmodule

