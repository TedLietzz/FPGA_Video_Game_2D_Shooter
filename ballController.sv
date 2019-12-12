module ballController (input Clk, p2,
							  input done1, done2, done3, done4,
							  input[7:0] keycode_0, keycode_1, keycode_2, keycode_3, keycode_4, keycode_5,
							  //output logic ready1, ready2, ready3, ready4,
							  output logic [3:0] select,
							  output logic [3:0] direction
							  );
		logic[3:0] which_ball;
		assign select = which_ball;
		logic ready;
		logic[27:0] count;
		logic up, down, left, right;
		
		assign right = keycode_0==8'd79 || keycode_1==8'd79 || keycode_2==8'd79 || keycode_3==8'd79 || keycode_4==8'd79 || keycode_5==8'd79;
		assign left = keycode_0==8'd80 || keycode_1==8'd80 || keycode_2==8'd80 || keycode_3==8'd80 || keycode_4==8'd80 || keycode_5==8'd80;
		assign down = keycode_0==8'd81 || keycode_1==8'd81 || keycode_2==8'd81 || keycode_3==8'd81 || keycode_4==8'd81 || keycode_5==8'd81;
		assign up = keycode_0==8'd82 || keycode_1==8'd82 || keycode_2==8'd82 || keycode_3==8'd82 || keycode_4==8'd82 || keycode_5==8'd82;

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
		 
		 if(right)
			begin
				direction <= 4'b0100;
			end
		 else if(left)
			begin
				direction <= 4'b1000;
			end
		 else if(down)
			begin
				direction <= 4'b0010;
			end
		 else if(up)
			begin
				direction <= 4'b0001;
			end   
		 
		 if( done1 == 1'b1 && ready == 1'b1 && (right || left || down || up))
                begin
                    //ready1 = 1'b1;
						  which_ball <= 4'b0001; 
						  count <= 28'b0;
                end  
				else if ( done2 == 1'b1 && ready == 1'b1 && (right || left || down || up))
                begin  
                    //ready2 = 1'b1;
						  which_ball <= 4'b0010;
						  count <= 28'b0;
                end
            else if ( done3 == 1'b1 && ready == 1'b1 && (right || left || down || up) && ~p2)  
                begin
                    //ready3 = 1'b1;
						  which_ball <= 4'b0100;
						  count <= 28'b0;
                end
				else if ( done4 == 1'b1 && ready == 1'b1 && (right || left || down || up) && ~p2)
                begin
                    //ready4 = 1'b1;
						  which_ball <= 4'b1000;
						  count <= 28'b0;
                end
				else
					begin
						which_ball <= 4'b0;
					end
		 end		  
endmodule
