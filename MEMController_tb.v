`timescale 1ms/1ms

module MEMController_tb		
            #(	
                parameter Addr_Width = 4,
                parameter Ram_Depth = 1 << Addr_Width,
                parameter Nums_SRAM_In = 2,
                parameter Nums_SRAM_Out = 1,
                parameter Nums_SRAM = Nums_SRAM_In + Nums_SRAM_Out,
                parameter Nums_Data_in_bits = 2,
                parameter Nums_Data = 1 << Nums_Data_in_bits,
                parameter Nums_Pipeline_Stages = 4,
                parameter Pipeline_Tail = Nums_Pipeline_Stages - 1,
                parameter Total_Computation_Steps = Nums_Data + Pipeline_Tail,
                parameter Para_Deg = 1
            )
            ();
            
            reg clk, Mem_reset, Comp_reset, Mem_Index_reset, load_from_file, Computing, write_to_file;
            wire [Nums_SRAM - 1:0] Mem_Clear, En_Chip_Select, En_Write, En_Read;
            wire [Nums_SRAM * Addr_Width - 1:0] Addr_Read , Addr_Write;

            wire loading_signal = 0, computing_signal = 0, write_to_file_signal = 0;
            wire [Nums_Data_in_bits:0] test;
            wire [Addr_Width:0] mem_index_test;

            MEMController #(.Addr_Width(Addr_Width), .Ram_Depth(Ram_Depth), .Nums_SRAM_In(Nums_SRAM_In), .Nums_SRAM_Out(Nums_SRAM_Out), 
            .Nums_SRAM(Nums_SRAM), .Nums_Data_in_bits(Nums_Data_in_bits), .Nums_Data(Nums_Data), .Nums_Pipeline_Stages(Nums_Pipeline_Stages),
            .Pipeline_Tail(Pipeline_Tail), .Total_Computation_Steps(Total_Computation_Steps), .Para_Deg(Para_Deg))
            dut (clk, Mem_reset, Comp_reset, Mem_Index_reset, load_from_file, Computing, write_to_file, loading_signal, computing_signal, write_to_file_signal,
                Mem_Clear, En_Chip_Select, En_Write, En_Read, Addr_Read, Addr_Write, 
                test, mem_index_test);

            initial begin
                clk = 1;
                Mem_reset = 1;
                Comp_reset = 1;
                Mem_Index_reset = 1;
                load_from_file = 0;
                Computing = 0;
                #2
                Mem_reset = 0;
                Comp_reset = 0;
                Mem_Index_reset = 0;
                load_from_file = 0;
                Computing = 1;
                #2
                Computing = 0;
            end
            
            always #1 clk = ~clk;

            integer Ram_Index = 0;

            always #2 begin
                $display("time:%0d, Mem_reset =%b, Comp_reset =%b, Mem_Index_reset =%b, load_from_file =%b, Computing= %b, test =%d",
                $time, Mem_reset, Comp_reset, Mem_Index_reset, load_from_file, Computing, test);
                for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: showSignals
                    $display("RAM%0d: Mem_Clear =%b, En_Chip_Select =%b, En_Write =%b, En_Read=%b, Addr_Read =%d, Addr_Write =%d", 
                    Ram_Index, Mem_Clear[Ram_Index], En_Chip_Select[Ram_Index], En_Write[Ram_Index], En_Read[Ram_Index], 
                    Addr_Read[Addr_Width * Ram_Index +: Addr_Width], Addr_Write[Addr_Width * Ram_Index +: Addr_Width]);
                end
            end
endmodule
