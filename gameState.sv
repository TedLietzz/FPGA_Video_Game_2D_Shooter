module gameState (   input logic Clk, 
									Reset,
									dead,
							input[7:0] keycode,
				output logic[19:0] sram_offset,
				output logic restart,
				output logic in_game,
				output logic p2, dead_state			
				);

	enum logic [2:0] { start, 
							 game, 
							 rip, 
							 restart_state,
							 restart_state2,
							 two_player
							}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= start;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		sram_offset = 20'b0;
		restart = 1'b0;
		in_game = 1'b0;
		p2 = 1'b0;
		dead_state = 1'b0;
	
		// Assign next state
		unique case (State)
			start : begin
				if (keycode == 8'd30) 
					Next_state = restart_state; 
				else if(keycode == 8'd31)
					Next_state = restart_state2;
			end
			game : 
				if (keycode == 8'b00001000 || dead == 1'b1) //if press 'e' or dead, go to end screen
					Next_state = rip;
			two_player: 
				if (keycode == 8'b00001000 || dead == 1'b1) //if press 'e' or dead, go to end screen
					Next_state = rip;
			rip :
				if (keycode == 8'd40)
					Next_state = start;
			restart_state :
					Next_state = game;
			restart_state2 :
					Next_state = two_player;
		endcase
		
		// Assign control signals based on current state
		case (State)
			start: ; //temporary for testing, delete after finished game
			game : 
				begin 
					in_game = 1'b1;
					sram_offset = 20'h4B000;
				end
			two_player : 
				begin 
					in_game = 1'b1;
					p2 = 1'b1;
					sram_offset = 20'h4B000;
				end
			rip :
				begin
					dead_state = 1'b1;
					sram_offset = 20'h4B000;					
				end
			restart_state :
				begin
					restart = 1'b1;
				end
			restart_state2 :
				begin
					restart = 1'b1;
				end
			default : ;
		endcase
	end 
endmodule
