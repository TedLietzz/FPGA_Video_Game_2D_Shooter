/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  AstroSprite
(
		//input [4:0] data_In,
		//input [18:0] write_address, 
		input [18:0] read_address1, read_address2,
		input Clk,

		output logic [3:0] data_Out1, data_Out2
);

// mem has width of 16 bits and a total of 550 addresses
logic [3:0] mem [0:549];

initial
begin
	 $readmemh("palette_astro1.txt", mem);
end

always_ff @ (posedge Clk) begin
	data_Out1<= mem[read_address1];
	data_Out2<=mem[read_address2];
end

endmodule