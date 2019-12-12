//-------------------------------------------------------------------------
//	Ball.sv                                                        	--
//	jiyeoni2 tlietz2                                               	--
//	Fall '19 ECE385                                                	--
//-------------------------------------------------------------------------


module  ball ( input     	Clk,            	// 50 MHz clock
                         	Reset,          	// Active-high reset signal
									restart,
                         	frame_clk,      	// The clock indicating a new frame (~60Hz)
            	input [7:0]  keycode,
            	input [9:0]   DrawX, DrawY,   	// Current pixel coordinates
	   			input logic [3:0] direction,
	   			input logic [9:0] astro_X_Pos, astro_Y_Pos,
	   			input  ready_use, kill, 
				input logic gunboost_use,
	   			output logic done_use,
	   			output logic [9:0] ball_X_Pos, ball_Y_Pos,
            	output logic  is_ball        	// Whether current pixel belongs to ball or background
            	);
   
//parameter [9:0] Ball_X_Center = astro_X_Pos;   // Center position on the X axis
//parameter [9:0] Ball_Y_Center = astro_Y_Pos;   // Center position on the Y axis
parameter [9:0] Ball_X_Min = 10'd0;   	// Leftmost point on the X axis
parameter [9:0] Ball_X_Max = 10'd479; 	// Rightmost point on the X axis
parameter [9:0] Ball_Y_Min = 10'd0;   	// Topmost point on the Y axis
parameter [9:0] Ball_Y_Max = 10'd479; 	// Bottommost point on the Y axis
//parameter [9:0] Ball_X_Step = 10'd1;   	// Step size on the X axis
//parameter [9:0] Ball_Y_Step = 10'd1;   	// Step size on the Y axis
parameter [9:0] Ball_Size = 10'd1;     	// Ball size


logic [9:0] Ball_X_Step, Ball_Y_Step;

logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
logic up, right, down, left;
logic up_in, right_in, down_in, left_in;
logic done;

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
	if (Reset || restart || kill)
    	begin
        	Ball_X_Pos <= astro_X_Pos;
        	Ball_Y_Pos <= astro_Y_Pos;
        	Ball_X_Motion <= 10'd0;
        	Ball_Y_Motion <= 10'd0;
   		 up <= 1'b1;
   		 down <= 1'b0;
   		 right <= 1'b0;
   		 left <= 1'b0;
   		 done_use <= 1'b1;
			Ball_X_Step <= 10'd2;
			Ball_Y_Step <= 10'd2;
    	end
	else if (direction[0] && ready_use && gunboost_use)
    	begin
			Ball_X_Step <= 10'd6;
			Ball_Y_Step <= 10'd6;
        	Ball_X_Pos <= astro_X_Pos;
        	Ball_Y_Pos <= astro_Y_Pos-(10'd11);
        	Ball_X_Motion <= 10'd0;
        	Ball_Y_Motion <= Ball_Y_Step;
        	up <= direction[0];
        	down <= direction[1];
        	right <= direction[2];
        	left <= direction[3];
   		 done_use <= 1'b0;
    	end
	else if (direction[1] && ready_use  && gunboost_use)
    	begin
			Ball_X_Step <= 10'd6;
			Ball_Y_Step <= 10'd6;
        	Ball_X_Pos <= astro_X_Pos;
        	Ball_Y_Pos <= astro_Y_Pos+(10'd11);
        	Ball_X_Motion <= 10'd0;
        	Ball_Y_Motion <= Ball_Y_Step;
        	up <= direction[0];
        	down <= direction[1];
        	right <= direction[2];
        	left <= direction[3];
   		 	done_use <= 1'b0;
    	end
	else if (direction[2] && ready_use && gunboost_use)
    	begin
			Ball_X_Step <= 10'd6;
			Ball_Y_Step <= 10'd6;
        	Ball_X_Pos <= astro_X_Pos+(10'd13);
        	Ball_Y_Pos <= astro_Y_Pos;
        	Ball_X_Motion <= 10'd0;
        	Ball_Y_Motion <= Ball_Y_Step;
        	up <= direction[0];
        	down <= direction[1];
        	right <= direction[2];
        	left <= direction[3];
   			done_use <= 1'b0;

    	end
	else if (direction[3] && ready_use && gunboost_use)
    	begin
			Ball_X_Step <= 10'd6;
			Ball_Y_Step <= 10'd6;
        	Ball_X_Pos <= astro_X_Pos-(10'd13);
        	Ball_Y_Pos <= astro_Y_Pos;
        	Ball_X_Motion <= 10'd0;
        	Ball_Y_Motion <= Ball_Y_Step;
        	up <= direction[0];
        	down <= direction[1];
        	right <= direction[2];
        	left <= direction[3];
   			done_use <=  1'b0;
    	end
	else if (direction[0] && ready_use && ~gunboost_use)
    	begin
			Ball_X_Step <= 10'd2;
			Ball_Y_Step <= 10'd2;
        	Ball_X_Pos <= astro_X_Pos;
        	Ball_Y_Pos <= astro_Y_Pos-(10'd11);
        	Ball_X_Motion <= 10'd0;
        	Ball_Y_Motion <= Ball_Y_Step;
        	up <= direction[0];
        	down <= direction[1];
        	right <= direction[2];
        	left <= direction[3];
   		 	done_use <= 1'b0;
    	end
	else if (direction[1] && ready_use  && ~gunboost_use)
    	begin
        	Ball_X_Pos <= astro_X_Pos;
        	Ball_Y_Pos <= astro_Y_Pos+(10'd11);
        	Ball_X_Motion <= 10'd0;
        	Ball_Y_Motion <= Ball_Y_Step;
        	up <= direction[0];
        	down <= direction[1];
        	right <= direction[2];
        	left <= direction[3];
   		 	done_use <= 1'b0;
			Ball_X_Step <= 10'd2;
			Ball_Y_Step <= 10'd2;
    	end
	else if (direction[2] && ready_use && ~gunboost_use)
    	begin
        	Ball_X_Pos <= astro_X_Pos+(10'd13);
        	Ball_Y_Pos <= astro_Y_Pos;
        	Ball_X_Motion <= 10'd0;
        	Ball_Y_Motion <= Ball_Y_Step;
        	up <= direction[0];
        	down <= direction[1];
        	right <= direction[2];
        	left <= direction[3];
   			done_use <= 1'b0;
			Ball_X_Step <= 10'd2;
			Ball_Y_Step <= 10'd2;

    	end
	else if (direction[3] && ready_use && ~gunboost_use)
    	begin
        	Ball_X_Pos <= astro_X_Pos-(10'd13);
        	Ball_Y_Pos <= astro_Y_Pos;
        	Ball_X_Motion <= 10'd0;
        	Ball_Y_Motion <= Ball_Y_Step;
        	up <= direction[0];
        	down <= direction[1];
        	right <= direction[2];
        	left <= direction[3];
   			done_use <=  1'b0;
			Ball_X_Step <= 10'd2;
			Ball_Y_Step <= 10'd2;
    	end
	else
    	begin
        	Ball_X_Pos <= Ball_X_Pos_in;
        	Ball_Y_Pos <= Ball_Y_Pos_in;
        	Ball_X_Motion <= Ball_X_Motion_in;
        	Ball_Y_Motion <= Ball_Y_Motion_in;
        	up <= up_in;
        	left <= left_in;
        	right <= right_in;
        	down <= down_in;
			done_use <= done;
			Ball_X_Step <= Ball_X_Step;
			Ball_Y_Step <= Ball_Y_Step;
    	end
	end
//////// Do not modify the always_ff blocks. ////////
   
// You need to modify always_comb block.
always_comb
	begin
    	// By default, keep motion and position unchanged
    	Ball_X_Pos_in = Ball_X_Pos;
    	Ball_Y_Pos_in = Ball_Y_Pos;
    	Ball_X_Motion_in = Ball_X_Motion;
    	Ball_Y_Motion_in = Ball_Y_Motion;
    	up_in = up;
    	left_in = left;
    	right_in = right;
    	down_in = down;
		done = done_use;
    	// Update position and motion only at rising edge of frame clock
    	if (frame_clk_rising_edge)
    	begin
        	// Be careful when using comparators with "logic" datatype because compiler treats
        	//   both sides of the operator as UNSIGNED numbers.
        	// e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min
        	// If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.


        	if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
   			 begin       
   			 done = 1'b1;
   			 Ball_X_Motion_in = 10'b0;
   			 Ball_Y_Motion_in = 10'b0;
   			 end
        	else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size)  // Ball is at the top edge, BOUNCE!
   			 begin   	 
   			 done = 1'b1;
   			 Ball_X_Motion_in = 10'b0;
   			 Ball_Y_Motion_in = 10'b0;
   			 end
        	else if ( Ball_X_Pos + Ball_Size >= Ball_X_Max)  //Ball at right edge, BOUNCE!
   			 begin
   			 done = 1'b1;
   			 Ball_X_Motion_in = 10'b0;
   			 Ball_Y_Motion_in = 10'b0;
   			 end
        	else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size )  // Ball is at the left edge, BOUNCE!
   			 begin    
   			 done = 1'b1;
   			 Ball_X_Motion_in = 10'b0;
   			 Ball_Y_Motion_in = 10'b0;
   			 end

        	if (left == 1)
            	begin
                	Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
                	Ball_Y_Motion_in = 10'd0;
                	up_in = 1'b0;
                	left_in = 1'b1;
                	right_in = 1'b0;
                	down_in = 1'b0;
            	end
        	else if (right == 1)
            	begin
                	Ball_X_Motion_in = Ball_X_Step;
                	Ball_Y_Motion_in = 10'd0;
                	up_in = 1'b0;
                	left_in = 1'b0;
                	right_in = 1'b1;
                	down_in = 1'b0;
            	end
        	else if (up == 1)
            	begin
                	Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
                	Ball_X_Motion_in = 10'd0;
                	up_in = 1'b1;
                	left_in = 1'b0;
                	right_in = 1'b0;
                	down_in = 1'b0;
            	end
        	else if (down == 1)
            	begin
                	Ball_Y_Motion_in = Ball_Y_Step;
                	Ball_X_Motion_in = 10'd0;
                	up_in = 1'b0;
                	left_in = 1'b0;
                	right_in = 1'b0;
                	down_in = 1'b1;
            	end
			
        	// Update the ball's position with its motion
        	Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
        	Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
    	end
 
	end
   
// Compute whether the pixel corresponds to ball or background
/* Since the multiplicants are required to be signed, we have to first cast them
	from logic to int (signed by default) before they are multiplied. */
int DistX, DistY, Size;
assign DistX = DrawX - Ball_X_Pos;
assign DistY = DrawY - Ball_Y_Pos;
assign Size = Ball_Size;
always_comb
	begin
    	if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) && done == 1'b0)
        	is_ball = 1'b1;
    	else
        	is_ball = 1'b0;
    	/* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while
        	the single line is quite powerful descriptively, it causes the synthesis tool to use up three
        	of the 12 available multipliers on the chip! */
	end
   
endmodule


