`timescale 100ns/100ns

module multiplier_tb
		#(
			parameter data_width = 8)
		();
		
		reg [data_width-1:0] in_data0, in_data1;
		wire [data_width*2-1:0] out_data;
		
		multiplier #(.data_width(data_width)) mul(in_data0, in_data1, out_data);
		
		initial begin
			in_data0 = 0;
			in_data1 = 0;
		end
		
		always #1 in_data0 = in_data0 + 1;
		always #1 in_data1 = in_data1 + 10;
		
endmodule
