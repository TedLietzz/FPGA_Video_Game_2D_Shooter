module  color_palette(
		input Clk,
		input [15:0] in,
		output logic [23:0] color_out
);

always_ff @ (negedge Clk)
	case (in)
	16'h0000: color_out <= 24'h0;    
	16'h0001: color_out <= 24'h141010;   
	16'h0010: color_out <= 24'h1d840f;    
	16'h0011: color_out <= 24'hffffff;
	16'h0100: color_out <= 24'hde8c36;    
	16'h0101: color_out <= 24'h073a68;    
	16'h0110: color_out <= 24'h788583;    
	16'h0111: color_out <= 24'h6e6e70;
	16'h1000: color_out <= 24'h46454c;    
	16'h1001: color_out <= 24'h433631;    
	16'h1010: color_out <= 24'h7f6e5f;    
	16'h1011: color_out <= 24'h6d4824;
	16'h1100: color_out <= 24'h3e1b02;    
	16'h1101: color_out <= 24'hebd2ba;    
	16'h1110: color_out <= 24'h014273;    
	16'h1111: color_out <= 24'hb2ced7;
	endcase
endmodule



module  color_palette_4bit(
		input Clk,
		input [3:0] in,
		output logic [23:0] color_out
);

always_ff @ (negedge Clk)
	case (in)
	4'h0: color_out <= 24'h0;    
	4'h1: color_out <= 24'h141010;   
	4'h2: color_out <= 24'h1d840f;    
	4'h3: color_out <= 24'hffffff;
	4'h4: color_out <= 24'hde8c36;    
	4'h5: color_out <= 24'h073a68;    
	4'h6: color_out <= 24'h788583;    
	4'h7: color_out <= 24'h6e6e70;
	4'h8: color_out <= 24'h46454c;    
	4'h9: color_out <= 24'h433631;    
	4'ha: color_out <= 24'h7f6e5f;    
	4'hb: color_out <= 24'h6d4824;
	4'hc: color_out <= 24'h3e1b02;    
	4'hd: color_out <= 24'hebd2ba;    
	4'he: color_out <= 24'h014273;    
	4'hf: color_out <= 24'hb2ced7;
	endcase
endmodule