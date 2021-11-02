`timescale 1ms/1ms

module MEMController_tb		
            #(	
            parameter Addr_Width = 4,
			parameter Ram_Depth = 1 << Addr_Width,
			parameter Nums_SRAM = 3,
			parameter bits_Computation = 4,
			parameter Nums_Computation = 1 << bits_Computation)
            ();
            
            reg clk, Mem_reset, Comp_reset, Mem_Index_reset, Computing, load_from_file;
            wire [Nums_SRAM - 1:0] Mem_Clear, En_Chip_Select, En_Write, En_Read;
            wire [Nums_SRAM * Addr_Width - 1:0] Addr_Read , Addr_Write;
            wire [bits_Computation-1:0] test;


            MEMController #(.Addr_Width(Addr_Width), .Ram_Depth(Ram_Depth), .Nums_SRAM(Nums_SRAM), .bits_Computation(bits_Computation), 
                            .Nums_Computation(Nums_Computation))
            dut(clk, Mem_reset, Comp_reset, Mem_Index_reset, Computing, load_from_file, 
                    Mem_Clear, En_Chip_Select, En_Write, En_Read, Addr_Read, Addr_Write, test);

            initial begin
                clk = 1;
                Mem_reset = 1;
                Comp_reset = 1;
                Mem_Index_reset = 1;
                Computing = 0;
                load_from_file = 0;
                #2
                Mem_reset = 0;
                Comp_reset = 0;
                Mem_Index_reset = 0;
                Computing = 0;
                load_from_file = 1;
                #34
                Computing = 1;
                load_from_file = 0;
                #34
                Computing = 0;
                load_from_file = 0;
            end
            
            always #1 clk = ~clk;

            integer Ram_Index = 0;

            always #2 begin
                $display("time:%0d, Mem_reset =%b, Comp_reset =%b, Mem_Index_reset =%b, Computing =%b, load_from_file =%b, test =%d",
                $time, Mem_reset, Comp_reset, Mem_Index_reset, Computing, load_from_file, test);
                for(Ram_Index = 0; Ram_Index < Nums_SRAM; Ram_Index = Ram_Index + 1) begin: showSignals
                    $display("RAM%0d: Mem_Clear =%b, En_Chip_Select =%b, En_Write =%b, En_Read=%b, Addr_Read =%d, Addr_Write =%d", 
                    Ram_Index, Mem_Clear[Ram_Index], En_Chip_Select[Ram_Index], En_Write[Ram_Index], En_Read[Ram_Index], 
                    Addr_Read[Addr_Width * Ram_Index +: Addr_Width], Addr_Write[Addr_Width * Ram_Index +: Addr_Width]);
                end
            end
endmodule
