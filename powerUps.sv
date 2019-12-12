//module powerUps (   input logic Clk, 
//									Reset,
//									speed_boost, bullet_boost, speeding, bullet_fast,
//							output logic astro_speed, bullet_speed
//				
//				);
//
//	enum logic [1:0] { none, 
//							 speed, 
//							 bullet, 
//							 speed&bullet,
//							}   State, Next_state;   // Internal state logic
//		
//	always_ff @ (posedge Clk)
//	begin
//		if (Reset) 
//			State <= start;
//		else 
//			State <= Next_state;
//	end
//   
//	always_comb
//	begin 
//		// Default next state is staying at current state
//		Next_state = State;
//		
//		// Default controls signal values
//		astro_speed = 1'b0;
//		bullet_speed = 1'b0;
//	
//		// Assign next state
//		unique case (State)
//			none : begin
//				if (speed_boost) 
//					Next_state = speed;
//				else if(bullet_boost)
//					Next_state = bullet;
//			end
//			speed : begin
//				if (bullet_boost) //if press 'e' or dead, go to end screen
//					Next_state = speed&bullet;
//			   else if(~speeding)
//					Next_state = none;
//			end
//			bullet : begin
//				if (speed_boost) //if press 'r'
//					Next_state = speed&bullet;
//				else if(~bullet_fast)
//					Next_state = none;
//			end
//			speed&bullet: begin 
//				if(~bullet_fast)
//					Next_state = speed;
//				else if(~speeding)
//					Next_state = bullet;
//			end
//		endcase
//		
//		// Assign control signals based on current state
//		case (State)
//			none: ;
//			speed : 
//				begin 
//					astro_speed = 1'b1;
//					bullet_speed = 1'b0;
//				end
//			bullet :
//				begin
//					astro_speed = 1'b0;
//					bullet_speed = 1'b1;
//				end
//			apeed&bullet :
//				begin
//					astro_speed = 1'b1;
//					bullet_speed = 1'b1;
//				end
//			default : ;
//		endcase
//	end 
//endmodule