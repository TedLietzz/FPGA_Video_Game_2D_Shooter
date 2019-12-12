module monsterController2 (input Clk,
							  input monster_done5, monster_done6, monster_done7, monster_done8,
							  output logic [3:0] select
							  );
							  
		logic[3:0] which_monster;
		assign select = which_monster;
		logic ready;
		logic[27:0] count;

		 always_ff @ (posedge Clk)
		 begin
		 if(count >= 28'h17D7840) // 50*10^6 / 2 = half of a second wait time before
			begin
				count<= count;
				ready <= 1'b1;
			end
		 else
			begin
				count <= count + 1;
				ready <= 1'b0;
			end
		 
		 if( monster_done5 == 1'b1 && ready == 1'b1)
                begin
                    //ready1 = 1'b1;
						  which_monster <= 4'b0001; 
						  count <= 28'b0;
                end  
				else if ( monster_done6 == 1'b1 && ready == 1'b1)
                begin  
                    //ready2 = 1'b1;
						  which_monster <= 4'b0010;
						  count <= 28'b0;
                end
            else if ( monster_done7 == 1'b1 && ready == 1'b1 )  
                begin
                    //ready3 = 1'b1;
						  which_monster <= 4'b0100;
						  count <= 28'b0;
                end
				else if ( monster_done8 == 1'b1 && ready == 1'b1 )
                begin
                    //ready4 = 1'b1;
						  which_monster <= 4'b1000;
						  count <= 28'b0;
                end
				else
					begin
						which_monster <= 4'b0;
					end
		 end		  
endmodule