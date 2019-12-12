module final_toplevel( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
             // VGA InterfaSRAM_SRAM_SRAM_SRAM_CE_N_N_N_N 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 InterfaSRAM_SRAM_SRAM_SRAM_CE_N_N_N_N
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
				 

				 
//              SDRAM InterfaSRAM_SRAM_SRAM_SRAM_CE_N_N_N_N for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,     //SDRAM Clock

//					SRAM acSRAM_SRAM_SRAM_SRAM_CE_N_N_N_Nss signals							
				 output logic SRAM_CE_N, SRAM_UB_N, SRAM_LB_N, SRAM_OE_N, SRAM_WE_N,
             output logic [19:0] SRAM_ADDR,
             inout wire [15:0] SRAM_DQ,
				 
	          //LED for debugging
				 output logic [3:0]  LEDG
				 //input		PS2_KBCLK, PS2_KBDAT
                    );
	 
    logic Reset_h, Clk;
    logic [7:0] keycode1;
	 logic [7:0] keycode2;
	 logic [7:0] keycode3;
	 logic [7:0] keycode4;
	 logic [7:0] keycode5;
	 logic [7:0] keycode6;
	 
	 //keyboard PS2(.Clk(Clk), .psClk(PS2_KBCLK), .psData(PS2_KBDAT), .reset(Reset), .keyCode(keycode4), .press());
	 
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     final_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode1_export(keycode1),
									  .keycode2_export(keycode2),
									  .keycode3_export(keycode3),
									  .keycode4_export(keycode4),
									  .keycode5_export(keycode5),
									  .keycode6_export(keycode6),
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
	);
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    VGA_controller vga_controller_instance(.Clk(Clk), .Reset(Reset_h),.*, .VGA_CLK(VGA_CLK), .DrawX(DRAWX), .DrawY(DRAWY));   
	 
	 logic [9:0] DRAWX, DRAWY;
	 logic isAstro;
	 logic isAstro2;
	 logic isBall1;
	 logic isBall2;
	 logic isBall3;
	 logic isBall4;
	 logic isBall5;
	 logic isBall6;
	 logic isMonster1;
	 logic isMonster2;
	 logic isMonster3;
	 logic isMonster4;
	 logic isMonster5;
	 logic isMonster6;
	 logic isMonster7;
	 logic isMonster8;
	 logic kill1;
	 logic kill2;
	 logic kill3;
	 logic kill4;
	 logic kill5;
	 logic kill6;
	 logic killed1;
	 logic killed2;
	 logic killed3;
	 logic killed4;
	 logic killed5;
	 logic killed6;
	 logic killed7;
	 logic killed8;
	 logic [3:0] direction;
	 logic [3:0] direction2;
	 logic [9:0] astro_x_pos;
	 logic [9:0] astro_y_pos;
	 logic [9:0] astro2_x_pos;
	 logic [9:0] astro2_y_pos;
	 logic [9:0] ball1_x_pos;
	 logic [9:0] ball1_y_pos;
	 logic [9:0] ball2_x_pos;
	 logic [9:0] ball2_y_pos;
	 logic [9:0] ball3_x_pos;
	 logic [9:0] ball3_y_pos;
	 logic [9:0] ball4_x_pos;
	 logic [9:0] ball4_y_pos;
	 logic [9:0] ball5_x_pos;
	 logic [9:0] ball5_y_pos;
	 logic [9:0] ball6_x_pos;
	 logic [9:0] ball6_y_pos;
	 logic [9:0] monster1_x_pos;
	 logic [9:0] monster1_y_pos;
	 logic [9:0] monster2_x_pos;
	 logic [9:0] monster2_y_pos;
	 logic [9:0] monster3_x_pos;
	 logic [9:0] monster3_y_pos;
	 logic [9:0] monster4_x_pos;
	 logic [9:0] monster4_y_pos;
	 logic [9:0] monster5_x_pos;
	 logic [9:0] monster5_y_pos;
	 logic [9:0] monster6_x_pos;
	 logic [9:0] monster6_y_pos;
	 logic [9:0] monster7_x_pos;
	 logic [9:0] monster7_y_pos;
	 logic [9:0] monster8_x_pos;
	 logic [9:0] monster8_y_pos;
	 logic [9:0] monster_spawn_x;
	 logic [9:0] monster_spawn_y;
	 logic [9:0] power_spawn_x;
	 logic [9:0] power_spawn_y;
	 
	 logic ready1, done1;
	 logic ready2, done2;
	 logic ready3, done3;
	 logic ready4, done4;
	 logic [3:0] ball_select;
	 assign ready1 = ball_select[0];
	 assign ready2 = ball_select[1];
	 assign ready3 = ball_select[2];
	 assign ready4 = ball_select[3];
	 
	 logic ready5, done5;
	 logic ready6, done6;
	 logic [3:0] ball_select2;
	 assign ready5 = ball_select2[0];
	 assign ready6 = ball_select2[1];
	 
	 logic monster_ready1, monster_done1;
	 logic monster_ready2, monster_done2;
	 logic monster_ready3, monster_done3;
	 logic monster_ready4, monster_done4;
	 logic [3:0] monster_select;
	 assign monster_ready1 = monster_select[0];
	 assign monster_ready2 = monster_select[1];
	 assign monster_ready3 = monster_select[2];
	 assign monster_ready4 = monster_select[3];
	 
	 logic monster_ready5, monster_done5;
	 logic monster_ready6, monster_done6;
	 logic monster_ready7, monster_done7;
	 logic monster_ready8, monster_done8;
	 logic [3:0] monster_select2;
	 assign monster_ready5 = monster_select2[0];
	 assign monster_ready6 = monster_select2[1];
	 assign monster_ready7 = monster_select2[2];
	 assign monster_ready8 = monster_select2[3];
	 
	 assign LEDG[0] = kill1;
	 assign LEDG[1] = kill2;
	 assign LEDG[2] = kill3;
	 assign LEDG[3] = 1'b1;
	 
	 logic isMonster;
	 assign isMonster = isMonster1 || isMonster2 || isMonster3 || isMonster4 || isMonster5 || isMonster6 || isMonster7 || isMonster8;
	 assign kill1 = isBall1 && isMonster;
	 assign kill2 = isBall2 && isMonster;
	 assign kill3 = isBall3 && isMonster;
	 assign kill4 = isBall4 && isMonster;
	 assign kill5 = isBall5 && isMonster;
	 assign kill6 = isBall6 && isMonster;
	 
	 logic isBall;
	 assign isBall = isBall1 || isBall2 || isBall3 || isBall4;
	 assign killed1 = isMonster1 && (isBall || isBall5 || isBall6);
	 assign killed2 = isMonster2 && (isBall || isBall5 || isBall6);
	 assign killed3 = isMonster3 && (isBall || isBall5 || isBall6);
	 assign killed4 = isMonster4 && (isBall || isBall5 || isBall6);
	 assign killed5 = isMonster5 && (isBall || isBall5 || isBall6);
	 assign killed6 = isMonster6 && (isBall || isBall5 || isBall6);
	 assign killed7 = isMonster7 && (isBall || isBall5 || isBall6);
	 assign killed8 = isMonster8 && (isBall || isBall5 || isBall6);
	 
    ballController bcontroller_instance(.*, .select(ball_select), .direction(direction),
	 .keycode_0(keycode1), .keycode_1(keycode2), .keycode_2(keycode3), .keycode_3(keycode4), .keycode_4(keycode5), .keycode_5(keycode6),
	 .p2(p2));
	
	 ballController2 bcontroller2_instance(.*, .select(ball_select2), .direction(direction2),
	 .keycode_0(keycode1), .keycode_1(keycode2), .keycode_2(keycode3), .keycode_3(keycode4), .keycode_4(keycode5), .keycode_5(keycode6),
	 .done1(done5), .done2(done6), 
	 .p2(p2));
	 
	 ball ball1(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_ball(isBall1), .keycode(keycode), .direction(direction),
	 .astro_X_Pos(astro_x_pos), .astro_Y_Pos(astro_y_pos), .ball_X_Pos(ball1_x_pos), .ball_Y_Pos(ball1_y_pos), .ready_use(ready1), .done_use(done1),
	 .restart(restart), .kill(kill1), .gunboost_use(bulletboost_use));
    
	 ball ball2(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_ball(isBall2), .keycode(keycode), .direction(direction),
	 .astro_X_Pos(astro_x_pos), .astro_Y_Pos(astro_y_pos), .ball_X_Pos(ball2_x_pos), .ball_Y_Pos(ball2_y_pos), .ready_use(ready2), .done_use(done2),
	 .restart(restart), .kill(kill2), .gunboost_use(bulletboost_use));
							  
	 ball ball3(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_ball(isBall3), .keycode(keycode), .direction(direction),
	 .astro_X_Pos(astro_x_pos), .astro_Y_Pos(astro_y_pos), .ball_X_Pos(ball3_x_pos), .ball_Y_Pos(ball3_y_pos), .ready_use(ready3), .done_use(done3),
	 .restart(restart), .kill(kill3), .gunboost_use(bulletboost_use));						  
	
	 ball ball4(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_ball(isBall4), .keycode(keycode), .direction(direction),
	 .astro_X_Pos(astro_x_pos), .astro_Y_Pos(astro_y_pos), .ball_X_Pos(ball4_x_pos), .ball_Y_Pos(ball4_y_pos), .ready_use(ready4), .done_use(done4),
	 .restart(restart), .kill(kill4), .gunboost_use(bulletboost_use));
	 
	 ball ball5(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_ball(isBall5), .keycode(keycode), .direction(direction2),
	 .astro_X_Pos(astro2_x_pos), .astro_Y_Pos(astro2_y_pos), .ball_X_Pos(ball5_x_pos), .ball_Y_Pos(ball5_y_pos), .ready_use(ready5), .done_use(done5),
	 .restart(restart), .kill(kill5), .gunboost_use(bulletboost_use));						  
	
	 ball ball6(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_ball(isBall6), .keycode(keycode), .direction(direction2),
	 .astro_X_Pos(astro2_x_pos), .astro_Y_Pos(astro2_y_pos), .ball_X_Pos(ball6_x_pos), .ball_Y_Pos(ball6_y_pos), .ready_use(ready6), .done_use(done6),
	 .restart(restart), .kill(kill6), .gunboost_use(bulletboost_use));
	 
	 monsterController mcontroller_instance(.*, .select(monster_select));
	 
	 monsterController2 mcontroller2_instance(.*, .select(monster_select2));
	 
	 monster2 enemy_instance1( .Clk(Clk), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_monster(isMonster1), .keycode(keycode),
	 .astro_X_Pos(astro_x_pos), .astro_Y_Pos(astro_y_pos), .monster_X_pos(monster1_x_pos), .monster_Y_pos(monster1_y_pos), .kill(killed1),
	 .spawn_x(monster_spawn_x), .spawn_y(monster_spawn_y), .ready_use(monster_ready1), .done_use(monster_done1), .restart(restart));
	 
	 monster enemy_instance2( .Clk(Clk), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_monster(isMonster2), .keycode(keycode),
	 .astro_X_Pos(astro_x_pos), .astro_Y_Pos(astro_y_pos), .monster_X_pos(monster2_x_pos), .monster_Y_pos(monster2_y_pos), .kill(killed2),
	 .spawn_x(monster_spawn_x), .spawn_y(monster_spawn_y), .ready_use(monster_ready2), .done_use(monster_done2), .restart(restart));
	 
	 monster2 enemy_instance3( .Clk(Clk), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_monster(isMonster3), .keycode(keycode),
	 .astro_X_Pos(astro_x_pos), .astro_Y_Pos(astro_y_pos), .monster_X_pos(monster3_x_pos), .monster_Y_pos(monster3_y_pos), .kill(killed3),
	 .spawn_x(monster_spawn_x), .spawn_y(monster_spawn_y), .ready_use(monster_ready3), .done_use(monster_done3), .restart(restart));
	 
	 monster enemy_instance4( .Clk(Clk), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_monster(isMonster4), .keycode(keycode),
	 .astro_X_Pos(astro_x_pos), .astro_Y_Pos(astro_y_pos), .monster_X_pos(monster4_x_pos), .monster_Y_pos(monster4_y_pos), .kill(killed4),
	 .spawn_x(monster_spawn_x), .spawn_y(monster_spawn_y), .ready_use(monster_ready4), .done_use(monster_done4), .restart(restart));
	 
	 logic [9:0] x_pos, y_pos;
	 
	 assign x_pos = p2 ? astro2_x_pos : astro_x_pos;
	 assign y_pos = p2 ? astro2_y_pos : astro_y_pos;
	 
	 monster enemy_instance5( .Clk(Clk), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_monster(isMonster5), .keycode(keycode),
	 .astro_X_Pos(x_pos), .astro_Y_Pos(y_pos), .monster_X_pos(monster5_x_pos), .monster_Y_pos(monster5_y_pos), .kill(killed5),
	 .spawn_x(monster_spawn_x), .spawn_y(monster_spawn_y), .ready_use(monster_ready5), .done_use(monster_done5), .restart(restart));
	 
	 monster2 enemy_instance6( .Clk(Clk), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_monster(isMonster6), .keycode(keycode),
	 .astro_X_Pos(x_pos), .astro_Y_Pos(y_pos), .monster_X_pos(monster6_x_pos), .monster_Y_pos(monster6_y_pos), .kill(killed6),
	 .spawn_x(monster_spawn_x), .spawn_y(monster_spawn_y), .ready_use(monster_ready6), .done_use(monster_done6), .restart(restart));
	 
	 monster enemy_instance7( .Clk(Clk), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_monster(isMonster7), .keycode(keycode),
	 .astro_X_Pos(x_pos), .astro_Y_Pos(y_pos), .monster_X_pos(monster7_x_pos), .monster_Y_pos(monster7_y_pos), .kill(killed7),
	 .spawn_x(monster_spawn_x), .spawn_y(monster_spawn_y), .ready_use(monster_ready7), .done_use(monster_done7), .restart(restart));
	 
	 monster2 enemy_instance8( .Clk(Clk), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_monster(isMonster8), .keycode(keycode),
	 .astro_X_Pos(x_pos), .astro_Y_Pos(y_pos), .monster_X_pos(monster8_x_pos), .monster_Y_pos(monster8_y_pos), .kill(killed8),
	 .spawn_x(monster_spawn_x), .spawn_y(monster_spawn_y), .ready_use(monster_ready8), .done_use(monster_done8), .restart(restart));
	 
	 Astro player_instance(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_astro(isAstro), 
	 .keycode_0(keycode1), .keycode_1(keycode2), .keycode_2(keycode3), .keycode_3(keycode4), .keycode_4(keycode5), .keycode_5(keycode6),
	 .astro_X_Pos(astro_x_pos), .astro_Y_Pos(astro_y_pos), .restart(restart), .speedboost_use(speedboost_use));
	 
	 Astro2 player2_instance(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .is_astro(isAstro2), 
	 .keycode_0(keycode1), .keycode_1(keycode2), .keycode_2(keycode3), .keycode_3(keycode4), .keycode_4(keycode5), .keycode_5(keycode6),
	 .astro_X_Pos(astro2_x_pos), .astro_Y_Pos(astro2_y_pos), .restart(restart), .p2(p2), .speedboost_use(speedboost_use));
	 
	 color_mapper color_instance(.*, .DrawX(DRAWX), .DrawY(DRAWY), .is_astro(isAstro), .bg_data(bg_data), .astro_data(astro_data),
	 .astro2_data(astro2_data), .is_astro2(isAstro2),
	 .monster1_data(monster1_data), .monster2_data(monster2_data), .monster3_data(monster3_data), .monster4_data(monster4_data),
	 .monster5_data(monster5_data), .monster6_data(monster6_data), .monster7_data(monster7_data), .monster8_data(monster8_data),
	 .isBall(isBall), .isBall5(isBall5), .isBall6(isBall6),
	 .is_monster1(isMonster1), .is_monster2(isMonster2), .is_monster3(isMonster3), .is_monster4(isMonster4),
	 .is_monster5(isMonster5), .is_monster6(isMonster6), .is_monster7(isMonster7), .is_monster8(isMonster8),
	 .in_game(in_game), .p2(p2),
	 .is_speedboost(is_speedboost), .speed_data(speed_data), .dead_state(dead_state), .dead_data(dead_data),
	 .is_bulletboost(is_bulletboost), .bullet_data(bullet_data), .is_end(is_end)
	 );
	 
	 deadSprite dead_instance(.read_address(dead_address), .Clk(Clk), .data_Out(dead_enc));
	 
	 speedSprite speed_instance(.read_address(speed_address), .Clk(Clk), .data_Out(speed_enc));
	 
	 bulletSprite bullet_instance(.read_address(bullet_address), .Clk(Clk), .data_Out(bullet_enc));
	 
	 AstroSprite astro_instance(.read_address1(astro_address), .read_address2(astro2_address), .Clk(Clk), .data_Out1(astro_enc), .data_Out2(astro2_enc));
	 
	 monsterSprite monster_instance(.read_address1(monster1_address), .read_address2(monster2_address), .read_address3(monster3_address), .read_address4(monster4_address),
	 .read_address5(monster5_address), .read_address6(monster6_address), .read_address7(monster7_address), .read_address8(monster8_address),
	 .Clk(Clk), .data_Out1(monster1_enc), .data_Out2(monster2_enc), .data_Out3(monster3_enc), .data_Out4(monster4_enc), 
	 .data_Out5(monster5_enc), .data_Out6(monster6_enc), .data_Out7(monster7_enc), .data_Out8(monster8_enc));
		
	 logic [23:0] astro_data, astro2_data, bg_data, monster1_data, monster2_data, monster3_data, monster4_data, monster5_data, monster6_data, monster7_data, monster8_data;
	 logic [18:0] astro_address, astro2_address, monster1_address, monster2_address, monster3_address, monster4_address, monster5_address, monster6_address, monster7_address, monster8_address;
	 logic [23:0] speed_data, bullet_data, dead_data;
	 logic [18:0] speed_address, bullet_address, dead_address;
	 
	 logic [9:0] end_X_Pos, end_Y_Pos;
	 
	 assign dead_address = (DRAWX - end_X_Pos) + (DRAWY - end_Y_Pos)*80;
	 assign bullet_address = (DRAWX - bulletboost_X_position) + (DRAWY - bulletboost_Y_position)*20;
	 assign speed_address = (DRAWX - speedboost_X_position) + (DRAWY - speedboost_Y_position)*20;
	 
	 //(DRAWX - astro_x_pos - astro_width_diff) + (DRAWY - astro_y_pos - astro_height_diff)*astro_width;
	 assign astro_address = (DRAWX - astro_x_pos - 10'd13) + (DRAWY - astro_y_pos - 10'd30)*25; 
	 
	 assign astro2_address = (DRAWX - astro2_x_pos - 10'd13) + (DRAWY - astro2_y_pos - 10'd30)*25;
	 assign monster1_address = (DRAWX - monster1_x_pos - 10'd17) + (DRAWY - monster1_y_pos - 10'd11)*22;
	 assign monster2_address = (DRAWX - monster2_x_pos - 10'd17) + (DRAWY - monster2_y_pos - 10'd11)*22;
	 assign monster3_address = (DRAWX - monster3_x_pos - 10'd17) + (DRAWY - monster3_y_pos - 10'd11)*22;
	 assign monster4_address = (DRAWX - monster4_x_pos - 10'd17) + (DRAWY - monster4_y_pos - 10'd11)*22;
	 assign monster5_address = (DRAWX - monster5_x_pos - 10'd17) + (DRAWY - monster5_y_pos - 10'd11)*22;
	 assign monster6_address = (DRAWX - monster6_x_pos - 10'd17) + (DRAWY - monster6_y_pos - 10'd11)*22;
	 assign monster7_address = (DRAWX - monster7_x_pos - 10'd17) + (DRAWY - monster7_y_pos - 10'd11)*22;
	 assign monster8_address = (DRAWX - monster8_x_pos - 10'd17) + (DRAWY - monster8_y_pos - 10'd11)*22;
	 
	 
	 logic[3:0] monster1_enc, monster2_enc, monster3_enc, monster4_enc, monster5_enc, monster6_enc, monster7_enc, monster8_enc;
	 logic[3:0] astro_enc, astro2_enc, speed_enc, bullet_enc, dead_enc;
	 logic[15:0] bg_enc;
	 
	 color_palette_4bit deadcolor(.Clk(Clk), .in(dead_enc), .color_out(dead_data));
	 color_palette_4bit bulletcolor(.Clk(Clk), .in(bullet_enc), .color_out(bullet_data));
	 color_palette_4bit speedcolor(.Clk(Clk), .in(speed_enc), .color_out(speed_data));
	 color_palette_4bit astro_color(.Clk(Clk), .in(astro_enc), .color_out(astro_data));
	 color_palette_4bit astro2_color(.Clk(Clk), .in(astro2_enc), .color_out(astro2_data));
	 color_palette_4bit bg_color(.Clk(Clk), .in(bg_enc[3:0]), .color_out(bg_data));
	 color_palette_4bit mcolor1(.Clk(Clk), .in(monster1_enc), .color_out(monster1_data));
	 color_palette_4bit mcolor2(.Clk(Clk), .in(monster2_enc), .color_out(monster2_data));
	 color_palette_4bit mcolor3(.Clk(Clk), .in(monster3_enc), .color_out(monster3_data));
	 color_palette_4bit mcolor4(.Clk(Clk), .in(monster4_enc), .color_out(monster4_data));
	 color_palette_4bit mcolor5(.Clk(Clk), .in(monster5_enc), .color_out(monster5_data));
	 color_palette_4bit mcolor6(.Clk(Clk), .in(monster6_enc), .color_out(monster6_data));
	 color_palette_4bit mcolor7(.Clk(Clk), .in(monster7_enc), .color_out(monster7_data));
	 color_palette_4bit mcolor8(.Clk(Clk), .in(monster8_enc), .color_out(monster8_data));

	 //spawn randomizer
	 logic[3:0] count;
	 always_ff @ (posedge Clk) begin
        if(in_game)
				count <= count+1;
			else if (count == 4'b1111)
				count <= 4'b0;
			else
				count <= 4'b0;
    end
	 
	 always_ff @ (posedge Clk) begin
        case (count[1:0])
			2'b00: begin 
				monster_spawn_x <= 10'd12;    
				monster_spawn_y <= 10'd240;
				power_spawn_x <= 10'd120;    
				power_spawn_y <= 10'd120;
					end
			2'b01: begin 
				monster_spawn_x <= 10'd240;    
				monster_spawn_y <= 10'd12;
				power_spawn_x <= 10'd240;    
				power_spawn_y <= 10'd120;
					end
			2'b10: begin 
				monster_spawn_x <= 10'd468;    
				monster_spawn_y <= 10'd240;
				power_spawn_x <= 10'd120;    
				power_spawn_y <= 10'd240;
					end
			2'b11: begin 
				monster_spawn_x <= 10'd240;    
				monster_spawn_y <= 10'd468;
				power_spawn_x <= 10'd240;    
				power_spawn_y <= 10'd240;
					end
			endcase
    end
	 
	 logic speedboost_hit, is_speedboost, speedboost_use;
	 logic [9:0] speedboost_X_position, speedboost_Y_position;
	 logic [9:0] bulletboost_X_position, bulletboost_Y_position;
	 
	 logic bulletboost_hit, is_bulletboost, bulletboost_use;
	 
	 assign speedboost_hit = (isAstro || isAstro2) && is_speedboost;
	 assign bulletboost_hit = (isAstro || isAstro2) && is_bulletboost;
	 
	 
	speedBoost speed(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .restart(restart), .DrawX(DRAWX), .DrawY(DRAWY), .score(score), 
	.speedboost_hit(speedboost_hit), .is_speedboost(is_speedboost), .speedboost_use(speedboost_use),
	.speedboost_X_position(speedboost_X_position), .speedboost_Y_position(speedboost_Y_position), .spawn_x(power_spawn_x), .spawn_y(power_spawn_y));
	 
	bulletBoost bullet(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS), .restart(restart), .DrawX(DRAWX), .DrawY(DRAWY), .score(score), 
	.bulletboost_hit(bulletboost_hit), .is_bulletboost(is_bulletboost), .bulletboost_use(bulletboost_use),
	.bulletboost_X_position(bulletboost_X_position), .bulletboost_Y_position(bulletboost_Y_position), .spawn_x(power_spawn_x), .spawn_y(power_spawn_y));
	 
	 //score calculating
	 logic [15:0] score;
	 logic kill; //1 if monster is killed, 0 otherwise
	 assign kill = killed1 || killed2 || killed3 || killed4 || killed5 || killed6 || killed7 || killed8; 
	 
	 HexDriver hex_inst_0 (score[3:0], HEX0);
    HexDriver hex_inst_1 (score[7:4], HEX1);
	 HexDriver hex_inst_2 (score[11:8], HEX2);
    HexDriver hex_inst_3 (score[15:12], HEX3);
	 
	 always_ff @ (posedge Clk) begin
        if(in_game)
			begin
				if(kill)
					score<=score+1;
				else 
					score<=score;
			end
		  else if (dead)
				score<=score;
		  else
			score<=0;			
    end
	 
	 //code to change between the start, game, and end screens
	 logic dead, dead1, dead2, is_end;
	 logic restart;
	 logic in_game, dead_state;
	 logic p2;
	 assign dead1 = isAstro && isMonster; //temporary to test screen changing
	 assign dead2 = isAstro2 && isMonster;
	 assign dead = dead1 || dead2;
	 gameState myGame(.Clk(Clk), .Reset(Reset_h), .restart(restart), .keycode(keycode1), 
	 .dead(dead), .in_game(in_game), .sram_offset(offset), .p2(p2), .dead_state(dead_state));
	 
	 ending myEnd(.Clk(Clk), .frame_clk(VGA_VS), .DrawX(DRAWX), .DrawY(DRAWY), .dead_state(dead_state), .end_X_Pos(end_X_Pos), .end_Y_Pos(end_Y_Pos), .is_end(is_end));
					
	 logic [19:0] offset;
	 assign SRAM_ADDR = DRAWX + DRAWY*640 + offset;
	 
	 //Program interaction with SRAM
	 assign SRAM_OE_N = 1'b0;
	 assign SRAM_WE_N = 1'b1;
	 assign SRAM_CE_N = 1'b0;
	 assign SRAM_UB_N = 1'b0;
	 assign SRAM_LB_N = 1'b0; 
	 logic OE;
	 logic [15:0] Data_from_SRAM; 
	 
	 Mem2IO memory_subsystem(
    .Clk(Clk), .Reset(Reset_h), .OE(OE), .ADDR(SRAM_ADDR),
    .Data_to_CPU(bg_enc), .Data_from_SRAM(Data_from_SRAM)   
    );
	 
	 tristate #(.N(16)) tr0(
    .Clk(Clk), .tristate_output_enable(~SRAM_WE_N), .Data_read(Data_from_SRAM), .Data(SRAM_DQ)
	 );
	 
endmodule

module Register (input [9:0] D, input Clk, output reg [9:0] Q);
	always_ff @(posedge Clk)
			Q <= D;
endmodule 
