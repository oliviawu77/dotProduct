module Dual_SRAM
		#(
		parameter data_width = 8,
		parameter addr_width = 4,
		parameter Ram_Depth = 1 << addr_width)
		(clk, Mem_Clear, Chip_Select, En_Write, En_Read, Write_Addr, Read_Addr, Write_Data, Read_Data);
			
			input clk, Mem_Clear, Chip_Select, En_Write, En_Read;
			input [addr_width-1:0] Write_Addr, Read_Addr;
			input [data_width-1:0] Write_Data;
			
			output [data_width-1:0] Read_Data;
			
			reg [data_width-1:0] Read_Data;
			reg [data_width-1:0] Mem_Data [0:Ram_Depth-1];
			
			integer Mem_Index;
			
			//Write
			always@(posedge clk) begin
				if(Mem_Clear) begin
					for(Mem_Index = 0; Mem_Index < Ram_Depth;Mem_Index = Mem_Index + 1) begin: ClearMemory
						Mem_Data[Mem_Index] <= 0;
					end
				end
				else if(Chip_Select && En_Write) begin
					Mem_Data[Write_Addr] <= Write_Data;
				end
				else begin
					for(Mem_Index = 0; Mem_Index < Ram_Depth;Mem_Index = Mem_Index + 1) begin: MemoryNoWrite
						Mem_Data[Mem_Index] <= Mem_Data[Mem_Index];
					end					
				end
			end
			
			//Read
			always@(posedge clk) begin
				if(!Mem_Clear && Chip_Select && En_Read) begin
					Read_Data <= Mem_Data[Read_Addr];
				end
				else begin
					Read_Data <= 0;
				end
			end
			
endmodule

