/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  monsterSprite
(
		input [18:0] read_address1, read_address2, read_address3, read_address4, read_address5, read_address6, read_address7, read_address8,
		input we, Clk,

		output logic [3:0] data_Out1, data_Out2, data_Out3, data_Out4, data_Out5, data_Out6, data_Out7, data_Out8
);

// mem has width of 16 bits and a total of 550 addresses
logic [3:0] mem [0:483];

initial
begin
	 $readmemh("palette_slug1.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out1<= mem[read_address1];
	data_Out2<= mem[read_address2];
	data_Out3<= mem[read_address3];
	data_Out4<= mem[read_address4];
	data_Out5<= mem[read_address5];
	data_Out6<= mem[read_address6];
	data_Out7<= mem[read_address7];
	data_Out8<= mem[read_address8];
end

endmodule