/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  bulletSprite
(
		//input [4:0] data_In,
		//input [18:0] write_address, 
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out
);

logic [3:0] mem [0:399];

initial
begin
	 $readmemh("palette_shoot.txt", mem);
end

always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end

endmodule
