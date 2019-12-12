//-------------------------------------------------------------------------
//	astro.sv                                                       	--
//	jiyeoni2 tlietz2                                               	--
//	Fall '19 ECE385                                                	--
//-------------------------------------------------------------------------


module  Astro2 ( input     	Clk,            	// 50 MHz clock
                         	Reset,          	// Active-high reset signal
                         	frame_clk,      	// The clock indicating a new frame (~60Hz)
									restart,
									p2,
            	input [7:0] keycode_0,
   			   input [7:0] keycode_1,
					input [7:0] keycode_2,
					input [7:0] keycode_3,
					input [7:0] keycode_4,
   			   input [7:0] keycode_5,
            	input [9:0]   DrawX,DrawY,   	// Current pixel coordinates
				input logic speedboost_use,
            	output logic  is_astro,        	// Whether current pixel belongs to astro or background
   			 output logic [9:0] astro_X_Pos, astro_Y_Pos
            	);
   
parameter [9:0] astro_X_Center = 10'd320;  // Center position on the X axis
parameter [9:0] astro_Y_Center = 10'd240;  // Center position on the Y axis
parameter [9:0] astro_X_Min = 10'd0;   	// Leftmost point on the X axis
parameter [9:0] astro_X_Max = 10'd479; 	// Rightmost point on the X axis
parameter [9:0] astro_Y_Min = 10'd0;   	// Topmost point on the Y axis
parameter [9:0] astro_Y_Max = 10'd479; 	// Bottommost point on the Y axis
//parameter [9:0] astro_X_Step = 10'd1;  	// Step size on the X axis
//parameter [9:0] astro_Y_Step = 10'd1;  	// Step size on the Y axis

parameter [9:0] astro_Width = 10'd25;   	// astro width
parameter [9:0] astro_Height = 10'd22;  	// astro height
parameter [9:0] astro_Width_Diff = 10'd13;   	// astro width/2
parameter [9:0] astro_Height_Diff = 10'd11;  	// astro height/2
   
logic [9:0] astro_X_Step, astro_Y_Step;

logic [9:0] astro_X_Motion, astro_Y_Motion;
logic [9:0] astro_X_Pos_in, astro_X_Motion_in, astro_Y_Pos_in, astro_Y_Motion_in;
logic up, right, down, left;
logic up_in, right_in, down_in, left_in;

logic w, a, s, d; //i, j, k, l
assign w = keycode_0 == 8'd12 || keycode_1 == 8'd12 || keycode_2 == 8'd12 || keycode_3 == 8'd12 || keycode_4 == 8'd12 || keycode_5 == 8'd12;
assign a = keycode_0 == 8'd13 || keycode_1 == 8'd13 || keycode_2 == 8'd13 || keycode_3 == 8'd13 || keycode_4 == 8'd13 || keycode_5 == 8'd13;
assign s = keycode_0 == 8'd14 || keycode_1 == 8'd14 || keycode_2 == 8'd14 || keycode_3 == 8'd14 || keycode_4 == 8'd14 || keycode_5 == 8'd14;
assign d = keycode_0 == 8'd15 || keycode_1 == 8'd15 || keycode_2 == 8'd15 || keycode_3 == 8'd15 || keycode_4 == 8'd15 || keycode_5 == 8'd15;

   
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
	if (Reset || restart)
    	begin
        	astro_X_Pos <= astro_X_Center;
        	astro_Y_Pos <= astro_Y_Center;
        	astro_X_Motion <= 10'd0;
        	astro_Y_Motion <= 10'd0;
        	up = 1'b1;
        	left = 1'b0;
        	right = 1'b0;
        	down = 1'b0;
			astro_X_Step = 10'd1;
			astro_Y_Step = 10'd1;
    	end
	else if (speedboost_use == 1'b0)
    	begin
        	astro_X_Pos <= astro_X_Pos_in;
        	astro_Y_Pos <= astro_Y_Pos_in;
        	astro_X_Motion <= astro_X_Motion_in;
        	astro_Y_Motion <= astro_Y_Motion_in;
        	up <= up_in;
        	left <= left_in;
        	right <= right_in;
        	down <= down_in;
			astro_X_Step = 10'd1;
			astro_Y_Step = 10'd1;
    	end
	else if (speedboost_use == 1'b1)
    	begin
        	astro_X_Pos <= astro_X_Pos_in;
        	astro_Y_Pos <= astro_Y_Pos_in;
        	astro_X_Motion <= astro_X_Motion_in;
        	astro_Y_Motion <= astro_Y_Motion_in;
        	up <= up_in;
        	left <= left_in;
        	right <= right_in;
        	down <= down_in;
			astro_X_Step = 10'd2;
			astro_Y_Step = 10'd2;
    	end
	else
    	begin
        	astro_X_Pos <= astro_X_Pos_in;
        	astro_Y_Pos <= astro_Y_Pos_in;
        	astro_X_Motion <= astro_X_Motion_in;
        	astro_Y_Motion <= astro_Y_Motion_in;
        	up <= up_in;
        	left <= left_in;
        	right <= right_in;
        	down <= down_in;
			astro_X_Step = 10'd1;
			astro_Y_Step = 10'd1;
    	end
	end
//////// Do not modify the always_ff blocks. ////////
   
// You need to modify always_comb block.
always_comb
	begin
    	// By default, keep motion and position unchanged
    	astro_X_Pos_in = astro_X_Pos;
    	astro_Y_Pos_in = astro_Y_Pos;
    	astro_X_Motion_in = astro_X_Motion;
    	astro_Y_Motion_in = astro_Y_Motion;
    	up_in = up;
    	left_in = left;
    	right_in = right;
    	down_in = down;
    	// Update position and motion only at rising edge of frame clock
    	if (frame_clk_rising_edge)
    	begin
        	// Be careful when using comparators with "logic" datatype because compiler treats
        	//   both sides of the operator as UNSIGNED numbers.
        	// e.g. astro_Y_Pos - astro_Size <= astro_Y_Min
        	// If astro_Y_Pos is 0, then astro_Y_Pos - astro_Size will not be -4, but rather a large positive number.
      	 
   		 if( astro_Y_Pos + astro_Height_Diff >= astro_Y_Max && s)  // astro is at the bottom edge, stop
            	begin
                	astro_Y_Motion_in = 10'd0;
                	astro_X_Motion_in = 10'd0;
                	up_in = 1'b0;
                	left_in = 1'b0;
                	right_in = 1'b0;
                	down_in = 1'b1;
            	end // 2's complement.  
        	else if ( astro_Y_Pos <= astro_Y_Min + astro_Height_Diff && w)  // astro is at the top edge, stop
            	begin  
                	astro_Y_Motion_in = 10'd0;
                	astro_X_Motion_in = 10'd0;
                	up_in = 1'b1;
                	left_in = 1'b0;
                	right_in = 1'b0;
                	down_in = 1'b0;
            	end
        	else if ( astro_X_Pos + astro_Width_Diff >= astro_X_Max && d)  //astro at right edge, stop
            	begin
                	astro_X_Motion_in = 10'd0;
                	astro_Y_Motion_in = 10'd0;
                	up_in = 1'b0;
                	left_in = 1'b0;
                	right_in = 1'b1;
                	down_in = 1'b0;
            	end
        	else if ( astro_X_Pos <= astro_X_Min + astro_Width_Diff && a)  // astro is at the left edge, stop
            	begin
                	astro_X_Motion_in = 10'd0;
                	astro_Y_Motion_in = 10'd0;
                	up_in = 1'b0;
                	left_in = 1'b1;
                	right_in = 1'b0;
                	down_in = 1'b0;
            	end


   		 else if (a && w) // left & up press
            	begin
                	astro_X_Motion_in = (~(astro_X_Step) + 1'b1);
                	astro_Y_Motion_in = (~(astro_Y_Step) + 1'b1);
                	up_in = 1'b1;
                	left_in = 1'b1;
                	right_in = 1'b0;
                	down_in = 1'b0;
            	end
        	else if (d && w) // right & up press
            	begin
                	astro_X_Motion_in = astro_X_Step;
                	astro_Y_Motion_in = (~(astro_Y_Step) + 1'b1);
                	up_in = 1'b1;
                	left_in = 1'b0;
                	right_in = 1'b1;
                	down_in = 1'b0;
            	end
   		 else if (a && s) // left & down press
            	begin
                	astro_X_Motion_in = (~(astro_X_Step) + 1'b1);
                	astro_Y_Motion_in = astro_Y_Step;
                	up_in = 1'b0;
                	left_in = 1'b1;
                	right_in = 1'b0;
                	down_in = 1'b1;
            	end
        	else if (d && s) // right & down press
            	begin
                	astro_X_Motion_in = astro_X_Step;
                	astro_Y_Motion_in = astro_Y_Step;
                	up_in = 1'b0;
                	left_in = 1'b0;
                	right_in = 1'b1;
                	down_in = 1'b1;
            	end


   		 else if (a) // left press
            	begin
                	astro_X_Motion_in = (~(astro_X_Step) + 1'b1);
                	astro_Y_Motion_in = 10'd0;
                	up_in = 1'b0;
                	left_in = 1'b1;
                	right_in = 1'b0;
                	down_in = 1'b0;
            	end
        	else if (d) // right press
            	begin
                	astro_X_Motion_in = astro_X_Step;
                	astro_Y_Motion_in = 10'd0;
                	up_in = 1'b0;
                	left_in = 1'b0;
                	right_in = 1'b1;
                	down_in = 1'b0;
            	end
        	else if (w) // up press
            	begin
                	astro_Y_Motion_in = (~(astro_Y_Step) + 1'b1);
                	astro_X_Motion_in = 10'd0;
                	up_in = 1'b1;
                	left_in = 1'b0;
                	right_in = 1'b0;
                	down_in = 1'b0;
            	end
        	else if (s) // down press
            	begin
                	astro_Y_Motion_in = astro_Y_Step;
                	astro_X_Motion_in = 10'd0;
                	up_in = 1'b0;
                	left_in = 1'b0;
                	right_in = 1'b0;
                	down_in = 1'b1;
            	end
   		 else
   			 begin
   		     	 astro_X_Motion_in = 10'd0;
   				 astro_Y_Motion_in = 10'd0;
            	end

        	// Update the astro's position with its motion
        	astro_X_Pos_in = astro_X_Pos + astro_X_Motion;
        	astro_Y_Pos_in = astro_Y_Pos + astro_Y_Motion;
    	end
 
	end
   
// Compute whether the pixel corresponds to astro or background
/* Since the multiplicants are required to be signed, we have to first cast them
	from logic to int (signed by default) before they are multiplied. */
int DistX, DistY, Size, Width, Height;
assign DistX = DrawX - astro_X_Pos;
assign DistY = DrawY - astro_Y_Pos;
assign Width = astro_Width_Diff;
assign Height = astro_Height_Diff;

always_comb
	begin
    	// if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) )
   	 if ( (DistX*DistX <= Width*Width) && (DistY*DistY <= Height*Height) && p2)
        	is_astro = 1'b1;
    	else
        	is_astro = 1'b0;
	end
   
endmodule


