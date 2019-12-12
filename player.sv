//-------------------------------------------------------------------------
//    player.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  Astro ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
                input [7:0]  keycode,
                input [9:0]   DrawX, DrawY,       // Current pixel coordinates
                output logic  is_player,            // Whether current pixel belongs to player or background
                output logic [3:0] LED
                );
   
parameter [9:0] player_X_Center = 10'd240;  // Center position on the X axis
parameter [9:0] player_Y_Center = 10'd240;  // Center position on the Y axis
parameter [9:0] player_X_Min = 10'd0;       // Leftmost point on the X axis
parameter [9:0] player_X_Max = 10'd479;     // Rightmost point on the X axis
parameter [9:0] player_Y_Min = 10'd0;       // Topmost point on the Y axis
parameter [9:0] player_Y_Max = 10'd479;     // Bottommost point on the Y axis
parameter [9:0] player_X_Step = 10'd1;      // Step size on the X axis
parameter [9:0] player_Y_Step = 10'd1;      // Step size on the Y axis
parameter [9:0] player_Size = 10'd4;        // player size
   
logic [9:0] player_X_Pos, player_X_Motion, player_Y_Pos, player_Y_Motion;
logic [9:0] player_X_Pos_in, player_X_Motion_in, player_Y_Pos_in, player_Y_Motion_in;
logic up, right, down, left;
logic up_in, right_in, down_in, left_in;

assign LED[0] = up;
assign LED[1] = down;
assign LED[2] = right;
assign LED[3] = left;
   
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
    if (Reset)
        begin
            player_X_Pos <= player_X_Center;
            player_Y_Pos <= player_Y_Center;
            player_X_Motion <= 10'd0;
            player_Y_Motion <= 10'd0;
            up = 1'b0;
            left = 1'b0;
            right = 1'b0;
            down = 1'b0;
        end
    else
        begin
            player_X_Pos <= player_X_Pos_in;
            player_Y_Pos <= player_Y_Pos_in;
            player_X_Motion <= player_X_Motion_in;
            player_Y_Motion <= player_Y_Motion_in;
            up <= up_in;
            left <= left_in;
            right <= right_in;
            down <= down_in;
        end
    end
//////// Do not modify the always_ff blocks. ////////
   
// You need to modify always_comb block.
always_comb
    begin
        // By default, keep motion and position unchanged
        player_X_Pos_in = player_X_Pos;
        player_Y_Pos_in = player_Y_Pos;
        player_X_Motion_in = player_X_Motion;
        player_Y_Motion_in = player_Y_Motion;
        up_in = up;
        left_in = left;
        right_in = right;
        down_in = down;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. player_Y_Pos - player_Size <= player_Y_Min
            // If player_Y_Pos is 0, then player_Y_Pos - player_Size will not be -4, but rather a large positive number.
            				
				if( player_Y_Pos + player_Size >= player_Y_Max && keycode == 8'b00010110)  // player is at the bottom edge, BOUNCE!
                begin
                    player_Y_Motion_in = 10'd0;
                    player_X_Motion_in = 10'd0;
                    up_in = 1'b0;
                    left_in = 1'b0;
                    right_in = 1'b0;
                    down_in = 1'b0;
                end // 2's complement.  
            else if ( player_Y_Pos <= player_Y_Min + player_Size && keycode == 8'b00011010)  // player is at the top edge, BOUNCE!
                begin  
                    player_Y_Motion_in = 10'd0;
                    player_X_Motion_in = 10'd0;
                    up_in = 1'b0;
                    left_in = 1'b0;
                    right_in = 1'b0;
                    down_in = 1'b0;
                end
            else if ( player_X_Pos + player_Size >= player_X_Max && keycode == 8'b00000111)  //player at right edge, BOUNCE!
                begin
                    player_X_Motion_in = 10'd0;
                    player_Y_Motion_in = 10'd0;
                    up_in = 1'b0;
                    left_in = 1'b0;
                    right_in = 1'b0;
                    down_in = 1'b0;
                end
            else if ( player_X_Pos <= player_X_Min + player_Size && keycode == 8'b00000100)  // player is at the left edge, BOUNCE!
                begin
                    player_X_Motion_in = 10'd0;
                    player_Y_Motion_in = 10'd0;
                    up_in = 1'b0;
                    left_in = 1'b0;
                    right_in = 1'b0;
                    down_in = 1'b0;
                end				 
				else if (keycode == 8'b00000100)
                begin
                    player_X_Motion_in = (~(player_X_Step) + 1'b1);
                    player_Y_Motion_in = 10'd0;
                    up_in = 1'b0;
                    left_in = 1'b1;
                    right_in = 1'b0;
                    down_in = 1'b0;
                end
            else if (keycode == 8'b00000111)
                begin
                    player_X_Motion_in = player_X_Step;
                    player_Y_Motion_in = 10'd0;
                    up_in = 1'b0;
                    left_in = 1'b0;
                    right_in = 1'b1;
                    down_in = 1'b0;
                end
            else if (keycode == 8'b00011010)
                begin
                    player_Y_Motion_in = (~(player_Y_Step) + 1'b1);
                    player_X_Motion_in = 10'd0;
                    up_in = 1'b1;
                    left_in = 1'b0;
                    right_in = 1'b0;
                    down_in = 1'b0;
                end
            else if (keycode == 8'b00010110)
                begin
                    player_Y_Motion_in = player_Y_Step;
                    player_X_Motion_in = 10'd0;
                    up_in = 1'b0;
                    left_in = 1'b0;
                    right_in = 1'b0;
                    down_in = 1'b1;
                end
				else 
					begin
						  player_X_Motion_in = 10'd0;
                    player_Y_Motion_in = 10'd0;
                    up_in = 1'b0;
                    left_in = 1'b0;
                    right_in = 1'b0;
                    down_in = 1'b0;
                end
					 				
            // Update the player's position with its motion
            player_X_Pos_in = player_X_Pos + player_X_Motion;
            player_Y_Pos_in = player_Y_Pos + player_Y_Motion;
        end
 
    end
   
// Compute whether the pixel corresponds to player or background
/* Since the multiplicants are required to be signed, we have to first cast them
    from logic to int (signed by default) before they are multiplied. */
int DistX, DistY, Size;
assign DistX = DrawX - player_X_Pos;
assign DistY = DrawY - player_Y_Pos;
assign Size = player_Size;
always_comb
    begin
        if ( ( DistX*DistX + DistY*DistY) <= (Size*Size) )
            is_player = 1'b1;
        else
            is_player = 1'b0;
        /* The player's (pixelated) circle is generated using the standard circle formula.  Note that while
            the single line is quite powerful descriptively, it causes the synthesis tool to use up three
            of the 12 available multipliers on the chip! */
    end
   
endmodule
