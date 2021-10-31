`timescale 100ns/100ns

module PEGroup_tb
			#(
				parameter data_width = 8,
				parameter para_deg = 3)
			();

			reg clk, reset, load_old_output;
			reg [para_deg * data_width - 1:0] data0, data1;
			reg [para_deg * data_width * 2 - 1:0] old_output;
			wire [para_deg * data_width * 2 - 1:0] result;
			
			PEGroup #(.data_width(data_width), .para_deg(para_deg)) pegroups(clk, reset, load_old_output, data0, data1, result, old_output);
			
			integer i;

			initial begin
				clk <= 1;
				reset <= 1;
				data0 <= 0;
				data1 <= 0;
				load_old_output <= 0;
				old_output <= 0;
				$display("time = %d, reset = %b, load_old_output = %b", $time, reset, load_old_output);
				for(i = 0; i < para_deg; i = i + 1) begin: displayDataInit
					$display("i = %d, old_output = %d, data0 =%d, data1 =%d, result =%d",
					i, old_output[2 * i * data_width +: 2 * data_width], data0[i * data_width +: data_width], data1[i * data_width +: data_width],
					result[2 * i * data_width +: 2 * data_width]); 
				end
				#1
				reset <= 0;
				load_old_output <= 1;
			end
			
			always #1 clk <= ~clk;
			
			always #2 begin
				for(i = 0; i < para_deg; i = i + 1) begin: assigndata
					data0[i * data_width +: 8] = {$random} %65536;
					data1[i * data_width +: 8] = {$random} %65536;
					old_output[2 * i * data_width +: 16]= {$random} %65536;
				end
			end			
			
			always #2 begin
				$display("time = %d, reset = %b, load_old_output = %b", $time, reset, load_old_output);
				for(i = 0; i < para_deg; i = i + 1) begin: displayDataAlways
					$display("i = %d, old_output = %d, data0 =%d, data1 =%d, result =%d",
					i, old_output[2 * i * data_width +: 2 * data_width], data0[i * data_width +: data_width], data1[i * data_width +: data_width],
					result[2 * i * data_width +: 2 * data_width]);
				end
			end

endmodule
