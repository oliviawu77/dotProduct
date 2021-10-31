`timescale 1ms/1ms
module SRAM_tb_weight #(	
					parameter data_width = 8,
					parameter addr_width = 4,
					parameter Ram_Depth = 1 << addr_width)
					();
		reg clk, Mem_Clear, Chip_Select, En_Write, En_Read;
		reg [addr_width-1:0] Write_Addr, Read_Addr;
		reg [data_width-1:0] Write_Data;

		reg [data_width-1:0] buffer;

			
		wire [data_width-1:0] Read_Data;
		
		Dual_SRAM sram(clk, Mem_Clear, Chip_Select, En_Write, En_Read, Write_Addr, Read_Addr, Write_Data, Read_Data);

		integer file;
		integer Read_Index = 0;

		initial begin
			clk <= 1;
			Mem_Clear <= 1;
			Chip_Select <= 0;
			En_Write <= 0;
			En_Read <= 0;
			Write_Addr <= 0;
			Read_Addr <= 0;
			Write_Data <= 0;
			
			file = $fopen("weight.txt","r");
			$display("loading...");
			for(Read_Index = 0; Read_Index < Ram_Depth; Read_Index = Read_Index + 1) begin: ReadFile
				#2
				Mem_Clear <= 0;
				Chip_Select <= 1;
				$fscanf(file, "%d", buffer);
				En_Write <= 1;
				Write_Addr <= Read_Index;
				Write_Data <= buffer;
			end
			$fclose(file);
			$display("loading complete!");
			#2
			En_Read <= 1;
			En_Write <= 0;
			Write_Addr <= 0;
			Read_Addr <= 0;
			#2
			En_Read <= 1;
			En_Write <= 0;
			Write_Addr <= 0;
			Read_Addr <= 1;
			#2
			En_Read <= 1;
			En_Write <= 0;
			Write_Addr <= 0;
			Read_Addr <= 2;
			#2
			En_Read <= 1;
			En_Write <= 0;
			Write_Addr <= 0;
			Read_Addr <= 3;
		end

		/*
		always #1 begin
			Chip_Select <= 1;
			Mem_Clear <= 0;
			En_Read <= 1;
			En_Write <= 0;
			Write_Addr <= 1;
			Read_Addr <= 1;
		end
		*/
		always #1 clk = ~clk;
		//always #2 Write_Data = Write_Data + 1;
		
		always #2 $display("Mem_Clear =%b, Chip_Select =%b, En_Write =%b, En_Read =%b, Write_Addr =%d, Read_Addr =%d, Write_Data =%d, Read_Data =%d"
				,Mem_Clear, Chip_Select, En_Write, En_Read, Write_Addr, Read_Addr, Write_Data, Read_Data);
endmodule
