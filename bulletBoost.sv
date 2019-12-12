//-------------------------------------------------------------------------
//	bulletboost.sv                                                       	--
//	jiyeoni2 tlietz2                                               	--
//	Fall '19 ECE385                                                	--
//-------------------------------------------------------------------------


module  bulletBoost ( input  Clk,            	// 50 MHz clock
                         	Reset,          	// Active-high reset signal
                         	frame_clk,      	// The clock indicating a new frame (~60Hz)
							restart,
            	input [9:0]   DrawX,DrawY,   	// Current pixel coordinates
            	input logic  is_astro,        	// Whether current pixel belongs to astro or background
             	input logic [9:0] spawn_x, spawn_y,
					input  logic [15:0] score,
					input logic bulletboost_hit,
					output logic is_bulletboost,
					output logic bulletboost_use,
                output logic [9:0] bulletboost_X_position, bulletboost_Y_position
            	);
   
parameter [9:0] bulletboost_X_Center = 10'd520;  // Center position on the X axis
parameter [9:0] bulletboost_Y_Center = 10'd340;  // Center position on the Y axis

parameter [9:0] bulletboost_Width = 10'd20;  
parameter [9:0] bulletboost_Height = 10'd20;
parameter [9:0] bulletboost_Width_Diff = 10'd10; 
parameter [9:0] bulletboost_Height_Diff = 10'd10;  

logic [9:0] bulletboost_X_Pos, bulletboost_Y_Pos;
logic [31:0] counter;
logic printboost, printboost2;

//////// Do not modify the always_ff blocks. ////////
// Detect rising edge of frame_clk
logic frame_clk_delayed, frame_clk_rising_edge;
always_ff @ (posedge Clk)
begin
    frame_clk_delayed <= frame_clk;
    frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
end

// Update registers
always_ff @ (posedge Clk)
begin
	if (restart || Reset)
		begin
			printboost <= 1'b0;
			printboost2 <= 1'b0;
			bulletboost_X_position <= spawn_x;
         bulletboost_Y_position <= spawn_y;
		end
	else if (score == 16'd15 && printboost == 1'b0)
        begin
            bulletboost_X_position <= spawn_x;
            bulletboost_Y_position <= spawn_y;
				printboost <= 1'b1;
				printboost2 <= 1'b0;
		end
		else if(printboost == 1'b1)
	begin
		bulletboost_X_position <= bulletboost_X_Pos;
      bulletboost_Y_position <= bulletboost_Y_Pos;
		if(bulletboost_hit) begin
			printboost<=1'b0;
			printboost2<=1'b1;
			end
		else 
		begin
			printboost<=1'b1;
			printboost2<=1'b0;
		end
	end
	else if(printboost2 == 1'b1)
	begin
		bulletboost_X_position <= bulletboost_X_Center;
      bulletboost_Y_position <= bulletboost_Y_Center;
		if(counter > 32'b0) begin
			printboost<=1'b0;
			printboost2<=1'b1;
			end
		else 
		begin
			printboost<=1'b0;
			printboost2<=1'b0;
		end
	end
	else
	begin
		bulletboost_X_position <= bulletboost_X_Pos;
      bulletboost_Y_position <= bulletboost_Y_Pos;
		printboost<= 1'b0;
		printboost2<=1'b0;
	end
end

always_comb
begin
bulletboost_X_Pos = bulletboost_X_position;
bulletboost_Y_Pos = bulletboost_Y_position;
end

always_ff @  (posedge Clk) begin
	if (bulletboost_hit == 1'b1)
		begin
		counter <= 32'd300000000;
		end
	else
		begin
			if(counter <= 32'h0)
				counter<=32'h0;
			else
				counter<=counter-1;
		end
end

always_comb
begin
	if(counter>32'h0)
		bulletboost_use = 1'b1;
	else begin
		bulletboost_use = 1'b0;
	end
end

// Compute whether the pixel corresponds to astro or background
/* Since the multiplicants are required to be signed, we have to first cast them
	from logic to int (signed by default) before they are multiplied. */
int DistX, DistY, Size, Width, Height;
assign DistX = DrawX - bulletboost_X_Pos;
assign DistY = DrawY - bulletboost_Y_Pos;
assign Width = bulletboost_Width_Diff;
assign Height = bulletboost_Height_Diff;

always_comb
	begin
   	 if (DistX <= bulletboost_Width && DistX >= 1'b0 && DistY <= bulletboost_Height && DistY >= 1'b0 && (printboost || printboost2))
        	is_bulletboost = 1'b1;
    	else
        	is_bulletboost = 1'b0;
	end
   
endmodule

