//-------------------------------------------------------------------------
//	monster.sv                                                     	--
//	jiyeoni2 tlietz2                                               	--
//	Fall '19 ECE385                                                   --
//-------------------------------------------------------------------------


module  monster ( input      Clk,                // 50 MHz clock
                             frame_clk,          // The clock indicating a new frame (~60Hz)
									  Reset,
									  restart,
									  kill,
                input [7:0]  keycode,
                input [9:0]  DrawX, DrawY,       // Current pixel coordinates
					 input logic [9:0] astro_X_Pos, astro_Y_Pos,
					 input logic [9:0] spawn_x, spawn_y,
                output logic is_monster,
					 output logic [9:0] monster_X_pos, monster_Y_pos,
					 input logic ready_use,
					 output logic done_use
                );
   
parameter [9:0] monster_X_Center = 10'd240;   // Center position on the X axis
parameter [9:0] monster_Y_Center = 10'd240;   // Center position on the Y axis
parameter [9:0] monster_X_Min = 10'd0;       // Leftmost point on the X axis
parameter [9:0] monster_X_Max = 10'd479;     // Rightmost point on the X axis
parameter [9:0] monster_Y_Min = 10'd0;       // Topmost point on the Y axis
parameter [9:0] monster_Y_Max = 10'd479;     // Bottommost point on the Y axis
parameter [9:0] monster_X_Step = 10'd1;       // Step size on the X axis
parameter [9:0] monster_Y_Step = 10'd1;       // Step size on the Y axis
parameter [9:0] monster_Size = 10'd1;         // monster size
parameter [9:0] monster_Width = 10'd22;       // monster width
parameter [9:0] monster_Height = 10'd22;       // monster height
parameter [9:0] monster_Width_Diff = 10'd11;       // monster width/2
parameter [9:0] monster_Height_Diff = 10'd11;      // monster height/2

parameter [9:0] Ball_Size = 10'd1;         // Ball size

logic [9:0] monster_X_Pos, monster_X_Motion, monster_Y_Pos, monster_Y_Motion;
logic [9:0] monster_X_Pos_in, monster_X_Motion_in, monster_Y_Pos_in, monster_Y_Motion_in;
int X_Astro, Y_Astro;
assign monster_X_pos = monster_X_Pos;
assign monster_Y_pos = monster_Y_Pos;
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
            monster_X_Pos <= spawn_x;
            monster_Y_Pos <= spawn_y;
            monster_X_Motion <= 10'd0;
            monster_Y_Motion <= 10'd0;
				X_Astro <= astro_X_Pos - spawn_x;
				Y_Astro <= astro_Y_Pos - spawn_y;
				done_use <= 1'b1;
        end
	 else if (ready_use)
    	begin
				monster_X_Pos <= spawn_x;
            monster_Y_Pos <= spawn_y;
            monster_X_Motion <= 10'd0;
            monster_Y_Motion <= 10'd0;
				X_Astro <= astro_X_Pos - spawn_x;
				Y_Astro <= astro_Y_Pos - spawn_y;
				done_use <= 1'b0;
    	end
    else
        begin
            monster_X_Pos <= monster_X_Pos_in;
            monster_Y_Pos <= monster_Y_Pos_in;
            monster_X_Motion <= monster_X_Motion_in;
            monster_Y_Motion <= monster_Y_Motion_in;
				X_Astro <= astro_X_Pos - monster_X_Pos_in;
				Y_Astro <= astro_Y_Pos - monster_Y_Pos_in;
				done_use <= done;
        end
    end
//////// Do not modify the always_ff blocks. ////////

// You need to modify always_comb block.
always_comb
    begin
        // By default, keep motion and position unchanged
        monster_X_Pos_in = monster_X_Pos;
        monster_Y_Pos_in = monster_Y_Pos;
        monster_X_Motion_in = monster_X_Motion;
        monster_Y_Motion_in = monster_Y_Motion;
		  done = done_use;

        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
            // Be careful when using comparators with "logic" datatype because compiler treats
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. monster_Y_Pos - monster_Size <= monster_Y_Min
            // If monster_Y_Pos is 0, then monster_Y_Pos - monster_Size will not be -4, but rather a large positive number.

            if( monster_Y_Pos + monster_Height_Diff >= monster_Y_Max )  // monster is at the bottom edge, BOUNCE!
                begin
                    monster_Y_Motion_in = (~(monster_Y_Step) + 1'b1);
                    monster_X_Motion_in = 10'd0;
                end // 2's complement.  
            else if ( monster_Y_Pos <= monster_Y_Min + monster_Height_Diff)  // monster is at the top edge, BOUNCE!
                begin  
                    monster_Y_Motion_in = monster_Y_Step;
                    monster_X_Motion_in = 10'd0;
                end
            else if ( monster_X_Pos + monster_Width_Diff >= monster_X_Max)  //monster at right edge, BOUNCE!
                begin
                    monster_X_Motion_in = (~(monster_X_Step) + 1'b1);
                    monster_Y_Motion_in = 10'd0;
                end
            else if ( monster_X_Pos <= monster_X_Min + monster_Width_Diff )  // monster is at the left edge, BOUNCE!
                begin
                    monster_X_Motion_in = monster_X_Step;
                    monster_Y_Motion_in = 10'd0;
                end

            else if (X_Astro < 0) // left
                begin
                    monster_X_Motion_in = (~(monster_X_Step) + 1'b1);
                    monster_Y_Motion_in = 10'd0;
                end
            else if (X_Astro > 0) // right
                begin
                    monster_X_Motion_in = monster_X_Step;
                    monster_Y_Motion_in = 10'd0;
                end
            else if (Y_Astro < 0) // up
                begin
                    monster_Y_Motion_in = (~(monster_Y_Step) + 1'b1);
                    monster_X_Motion_in = 10'd0;
                end
            else if (Y_Astro > 0) // down
                begin
                    monster_Y_Motion_in = monster_Y_Step;
                    monster_X_Motion_in = 10'd0;
                end
            else
                begin
                    monster_Y_Motion_in = 10'd0;
                    monster_X_Motion_in = 10'd0;
                end
				
				// Update the monster's position with its motion
				
					monster_X_Pos_in = monster_X_Pos + monster_X_Motion;
					monster_Y_Pos_in = monster_Y_Pos + monster_Y_Motion;
	
        end
 
    end
   
// Compute whether the pixel corresponds to monster or background
/* Since the multiplicants are required to be signed, we have to first cast them
    from logic to int (signed by default) before they are multiplied. */
int DistX, DistY, Size, Width, Height;
assign DistX = DrawX - monster_X_Pos;
assign DistY = DrawY - monster_Y_Pos;
assign Size = monster_Size;
assign Width = monster_Width_Diff;
assign Height = monster_Height_Diff;
always_comb
    begin
//        if( (monster_Y_Pos + monster_Height_Diff + Ball_Size) >= Ball_Y_Pos)  // monster is at the bottom edge, BOUNCE!
//            is_monster = 1'b0;
//
//        else if ( monster_Y_Pos <= (Ball_Y_Pos + Ball_Size + monster_Height_Diff) )  // monster is at the top edge, BOUNCE!
//            is_monster = 1'b0;
//
//        else if ( (monster_X_Pos + monster_Width_Diff + Ball_Size) >= Ball_X_Pos)  //monster at right edge, BOUNCE!
//            is_monster = 1'b0;
//
//        else if ( monster_X_Pos <= (Ball_X_Pos + monster_Width_Diff + Ball_Size) )  // monster is at the left edge, BOUNCE!
//            is_monster = 1'b0;
//
//        else 
		  if ( (DistX*DistX <= Width*Width) && (DistY*DistY <= Height*Height) && done == 1'b0)
            is_monster = 1'b1;
        else
            is_monster = 1'b0;
    end
   
endmodule
