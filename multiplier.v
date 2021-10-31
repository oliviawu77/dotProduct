module multiplier
		#(parameter data_width = 8)
		(in_data0, in_data1, out_data);
	
		input [data_width-1:0] in_data0, in_data1;
		output [data_width*2-1:0] out_data;
			
		assign out_data = in_data0 * in_data1;
			
endmodule
