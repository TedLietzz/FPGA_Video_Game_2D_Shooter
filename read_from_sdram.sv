//module read_from_sdram #(N = 24) (
//	input logic Clk, 
//	input logic tristate_output_enable,
//	input logic [N-1:0] Data_write, // Data from sdram
//	output logic [N-1:0] Data_read, // Data to sdram
//	inout wire [N-1:0] Data // inout bus to sdram
//);
//
//// Registers are needed between synchronized circuit and asynchronized SRAM 
//logic [N-1:0] Data_write_buffer, Data_read_buffer;
//
//always_ff @(posedge Clk)
//begin
//	// Always read data from the bus
//	Data_read_buffer <= Data;
//	// Always updated with the data from Mem2IO which will be written to the bus
//	Data_write_buffer <= Data_write;
//end
//
//// Drive (write to) Data bus only when tristate_output_enable is active.
//assign Data = tristate_output_enable ? Data_write_buffer : {N{1'bZ}};
//
//assign Data_read = Data_read_buffer;
//
//endmodule
