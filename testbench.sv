module testbench();


timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;


			logic Clk;
								logic	Reset;
								logic	dead;
							logic [7:0] keycode;
				logic [19:0] sram_offset;
				logic restart;
				 logic in_game;
		 logic p2;
		logic  dead_state;

                    

gameState myGamestate(.*);
// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
#1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end 

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
Reset = 1'b0;		// Toggle Rest
keycode = 8'b0;
dead = 1'b0;

#2 Reset = 1'b1;
#2 Reset = 1'b0;

keycode = 8'd30;  //go into 1 player game
#2;
keycode = 8'd0;

#10;

dead = 1'b1;    //exit to rip screen when dead
#2;
dead = 1'b0;

#10;

keycode = 8'd40;   //return to main menu when press enter
#2;
keycode = 8'd0;

#10;
 
keycode = 8'd31;   //enter 2 player game
#2;
keycode = 8'd0;    

#10;

keycode = 8'd8;   //exit game by pressing 'e'
#2;
keycode = 8'd0; 


#10;


end
endmodule