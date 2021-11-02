`timescale 100ns/100ns

module PEGroup_tb
			#(
				parameter Data_Width = 8,
				parameter Para_Deg = 3)
			();

			reg clk, reset, load_old_output;
			reg [Para_Deg * Data_Width - 1:0] data0, data1;
			reg [Para_Deg * Data_Width * 2 - 1:0] old_output;
			wire [Para_Deg * Data_Width * 2 - 1:0] result;
			
			PEGroup #(.Data_Width(Data_Width), .Para_Deg(Para_Deg)) pegroups(clk, reset, load_old_output, data0, data1, result, old_output);
			
			integer i;

			initial begin
				clk <= 1;
				reset <= 1;
				data0 <= 0;
				data1 <= 0;
				load_old_output <= 0;
				old_output <= 0;
				$display("time = %d, reset = %b, load_old_output = %b", $time, reset, load_old_output);
				for(i = 0; i < Para_Deg; i = i + 1) begin: displayDataInit
					$display("i = %d, old_output = %d, data0 =%d, data1 =%d, result =%d",
					i, old_output[2 * i * Data_Width +: 2 * Data_Width], data0[i * Data_Width +: Data_Width], data1[i * Data_Width +: Data_Width],
					result[2 * i * Data_Width +: 2 * Data_Width]); 
				end
				#1
				reset <= 0;
				load_old_output <= 1;
			end
			
			always #1 clk <= ~clk;
			
			always #2 begin
				for(i = 0; i < Para_Deg; i = i + 1) begin: assigndata
					data0[i * Data_Width +: 8] = {$random} %65536;
					data1[i * Data_Width +: 8] = {$random} %65536;
					old_output[2 * i * Data_Width +: 16]= {$random} %65536;
				end
			end			
			
			always #2 begin
				$display("time = %d, reset = %b, load_old_output = %b", $time, reset, load_old_output);
				for(i = 0; i < Para_Deg; i = i + 1) begin: displayDataAlways
					$display("i = %d, old_output = %d, data0 =%d, data1 =%d, result =%d",
					i, old_output[2 * i * Data_Width +: 2 * Data_Width], data0[i * Data_Width +: Data_Width], data1[i * Data_Width +: Data_Width],
					result[2 * i * Data_Width +: 2 * Data_Width]);
				end
			end

endmodule
