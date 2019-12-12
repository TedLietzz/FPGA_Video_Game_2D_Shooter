//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input              isBall, isBall5, isBall6,  // Whether current pixel belongs to ball 
							  input					is_astro, is_astro2,
							  input 					is_speedboost,
							  input 					is_bulletboost,
							  
							  input					in_game, p2, dead_state, is_end,
					
						     input 					is_monster1, is_monster2, is_monster3, is_monster4, is_monster5, is_monster6, is_monster7, is_monster8,
																				  
							  input logic	   [23:0] bg_data, speed_data, bullet_data,	  
							  input logic		[23:0] astro_data, astro2_data, dead_data,	  
							  input logic		[23:0] monster1_data, monster2_data, monster3_data, monster4_data, monster5_data, monster6_data, monster7_data, monster8_data, 
							  					 
							  
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output						  
                     );
    
    logic [7:0] Red, Green, Blue;
    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    always_comb
    begin
        if (is_astro == 1'b1 && in_game == 1'b1 && astro_data != 24'b0) 
        begin     
            Red = astro_data[23:16];
            Green = astro_data[15:8];
            Blue = astro_data[7:0];
        end
		  
		  else if (is_astro2 == 1'b1 && in_game == 1'b1 && astro2_data != 24'b0 && p2) 
        begin
            Red = astro2_data[23:16] - 8'h30;
            Green = astro2_data[15:8] - 8'h30;
            Blue = astro2_data[7:0] - 8'h30;
        end
		  
		  else if (isBall && in_game == 1'b1)
		  begin 
				Red = 8'hff;
            Green = 8'h95;
            Blue = 8'h0a;
		  end
		  
		  else if ((isBall5 || isBall6) && in_game == 1'b1 && p2)
		  begin 
				Red = 8'hff;
            Green = 8'h00;
            Blue = 8'h00;
		  end
		  
		  else if (is_monster1 == 1'b1 && in_game == 1'b1 && monster1_data != 24'b0)
		  begin  
				Red = monster1_data[23:16];
            Green = monster1_data[15:8];
            Blue = monster1_data[7:0];
			end
			
		  else if (is_monster2 == 1'b1 && in_game == 1'b1 && monster2_data != 24'b0)
		  begin  
				Red = monster2_data[23:16];
            Green = monster2_data[15:8];
            Blue = monster2_data[7:0];
			end
			
		  else if (is_monster3 == 1'b1 && in_game == 1'b1 && monster3_data != 24'b0)
		  begin  
				Red = monster3_data[23:16];
            Green = monster3_data[15:8];
            Blue = monster3_data[7:0];
			end
			
	     else if (is_monster4 == 1'b1 && in_game == 1'b1 && monster4_data != 24'b0)
		  begin  
				Red = monster4_data[23:16];
            Green = monster4_data[15:8];
            Blue = monster4_data[7:0];
			end
			
			else if (is_monster5 == 1'b1 && in_game == 1'b1 && monster5_data != 24'b0)
		  begin  
				Red = monster5_data[23:16];
            Green = monster5_data[15:8];
            Blue = monster5_data[7:0];
			end
			
		  else if (is_monster6 == 1'b1 && in_game == 1'b1 && monster6_data != 24'b0)
		  begin  
				Red = monster6_data[23:16];
            Green = monster6_data[15:8];
            Blue = monster6_data[7:0];
			end
			
		  else if (is_monster7 == 1'b1 && in_game == 1'b1 && monster7_data != 24'b0)
		  begin  
				Red = monster7_data[23:16];
            Green = monster7_data[15:8];
            Blue = monster7_data[7:0];
			end
			
	     else if (is_monster8 == 1'b1 && in_game == 1'b1 && monster8_data != 24'b0)
		  begin  
				Red = monster8_data[23:16];
            Green = monster8_data[15:8];
            Blue = monster8_data[7:0];
			end
		  
		  else if (is_speedboost == 1'b1 && in_game == 1'b1 && speed_data != 24'b0)
		  begin  
				Red = speed_data[23:16];
            Green = speed_data[15:8];
            Blue = speed_data[7:0];
			end
			
		  else if (is_bulletboost == 1'b1 && in_game == 1'b1 && bullet_data != 24'b0)
		  begin  
				Red = bullet_data[23:16];
            Green = bullet_data[15:8];
            Blue = bullet_data[7:0];
			end

		  else if (is_end == 1'b1)
		  begin  
				Red = dead_data[23:16];
            Green = dead_data[15:8];
            Blue = dead_data[7:0];
			end
		  
        else 
        begin
            Red = bg_data[23:16]; 
            Green = bg_data[15:8];
            Blue = bg_data[7:0];
		  end
    end 
    
endmodule

