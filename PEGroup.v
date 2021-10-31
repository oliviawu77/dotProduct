module PEGroup
			#(
			parameter data_width = 8,
			parameter para_deg = 4)
			(clk, reset, load_old_output, data0, data1, result, old_output);
			input clk, reset, load_old_output;
			input [para_deg * data_width - 1:0] data0, data1;
			input [para_deg * data_width * 2 - 1:0] old_output;
			output [para_deg * data_width * 2 - 1:0] result;
			
			
			wire [data_width * 2 - 1:0] mul_result [0:para_deg-1];
			
			reg [data_width * 2 - 1:0] tmp_result [0:para_deg-1];
			
			genvar PE_index;
			generate
				for(PE_index = 0; PE_index < para_deg; PE_index = PE_index + 1) begin: PEs
					multiplier #(.data_width(data_width)) mul(.in_data0(data0[data_width * (PE_index+1) - 1:data_width * PE_index]), 
					.in_data1(data1[data_width * (PE_index+1) - 1:data_width * PE_index]), .out_data(mul_result[PE_index]));
				end
			endgenerate
			
			integer acc_index;
			
			always@(posedge clk) begin
				if(reset) begin
					for(acc_index = 0; acc_index < para_deg; acc_index = acc_index + 1) begin: clearRegs
						tmp_result[acc_index] <= 0;
					end					
				end
				 if(load_old_output)begin
					for(acc_index = 0; acc_index < para_deg; acc_index = acc_index + 1) begin: accumulateWithOutput
						tmp_result[acc_index] <= old_output[2 * data_width * acc_index +:2 * data_width] + mul_result[acc_index];
					end
				end
				else begin	
					for(acc_index = 0; acc_index < para_deg; acc_index = acc_index + 1) begin: accumulate
						tmp_result[acc_index] <= mul_result[acc_index];
					end
				end
			end
			
			genvar out_index;
				generate
				for(out_index = 0; out_index < para_deg; out_index = out_index + 1) begin: output_connection
					assign result[data_width * 2 * out_index +:2 * data_width] = tmp_result[out_index];
					//assign result[2 * data_width * (out_index+1) - 1 :2 * data_width * out_index] = tmp_result[out_index];
				end
			endgenerate

endmodule
