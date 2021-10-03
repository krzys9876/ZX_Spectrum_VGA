`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:36:16 10/26/2018 
// Design Name: 
// Module Name:    tv80_01_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module tv80_01_top(
	input clk,
	input SW1,SW2,SW3,SW4,
	input [7:0] Lin, 
	input in_mreq,in_wr,in_iorq, // active low!
	output [7:0] LED,
	output o_vga_hs,o_vga_vs,
	output [3:0] o_r,
	 output [3:0] o_g,
	 output [3:0] o_b,
	 
	 output o_en_d,
	 output o_en_al,
	 output o_en_ah
    );
	 
	 reg [31:0] counter;
	 
	 wire clk_vga;
	 
	 wire rst_pos,rst;
	 	 
	 clk_divider clk_div
   (// Clock in ports
    .CLK_IN(clk),      // IN
    // Clock out ports
    .CLK_MASTER(clk_master),     // 100M
    .CLK_VGA(clk_vga)     // 25M
	 );
	 
	 wire vga_hs, vga_vs;
	 wire [9:0] vga_x,vga_sx;
	 wire [9:0] vga_y,vga_sy,vga_next_y,vga_next_sy,vga_sy_sh,vga_next_sy_sh;
	 wire vga_blank;
	 wire vga_blank_next;
	 wire [4:0] sx_cnt,sy_cnt;
	 wire [4:0] sx_counter,sy_counter;
	 wire [2:0] bit_num, bit_num_n;
	 wire [7:0] byte_num, byte_num_n, next_byte_num, next_byte_num_n, byte_num_sh, next_byte_num_sh;
	 
	 wire [7:0] x_shift;
	 wire [9:0] y_shift;
	 
	 wire [12:0] addr_wire;
	 reg [12:0] addr_reg;
	 
	 reg [9:0] addr_attr_reg;
	 reg [5:0] vs_counter;
	 reg [7:0] memwe_counter,memwe_counter_wr;

	 //assign o_memwe_counter[7:0]=memwe_counter[7:0];
	 
	 wire [7:0] vga_mem_rec,vga_attr_rec;
	 wire char_mode;
	 wire [6:0] char_index;
	 wire [7:0] data;
	 reg [7:0] data_reg, data_reg_tmp,data_attr_reg;
	 wire [7:0] data_attr;
	 wire [11:0] color_ink,color_paper;
	 
	 wire visible_area;
	 
	 // wyrodkowanie obrazu na ekranie
	 assign x_shift=4; // 3 bajty=32 pixele
	 assign byte_num_sh=byte_num-x_shift;
	 assign next_byte_num_sh=next_byte_num-x_shift;
	 
	 assign y_shift=24; // 24 pixele
	 assign vga_sy_sh=vga_sy-y_shift;
	 assign vga_next_sy_sh=vga_next_sy-y_shift;
	 	 
	 //assign visible_area=vga_sx<=255 && vga_sy<=191;
	 assign visible_area=byte_num_sh>=0 && byte_num_sh<=31 && vga_sy_sh>=0 && vga_sy_sh<=191; //256x192
	 assign o_bit=visible_area & data_reg[{3'b111-bit_num}];
	 assign data_attr=visible_area ? data_attr_reg : 8'b01111000; //szare to
	 
	 //  7:0 FLASH | BRIGHT | PEN_G | PEN_R | PEN_B | INK_G | INK_R | INK_B
   // po 4 bity w kolejnoci: 12:0 rrrrggggbbbb
	
	//assign color_ink=12'h000;
	//assign color_paper=12'hFFF;
	 assign color_ink=
		  (data_attr[2:0]==0) ? (data_attr[6] ? 12'h000 : 12'h000)
		: (data_attr[2:0]==1) ? (data_attr[6] ? 12'h00C : 12'h00F)
		: (data_attr[2:0]==2) ? (data_attr[6] ? 12'hC00 : 12'hF00)
		: (data_attr[2:0]==3) ? (data_attr[6] ? 12'hC0C : 12'hF0F)
		: (data_attr[2:0]==4) ? (data_attr[6] ? 12'h0C0 : 12'h0F0)
		: (data_attr[2:0]==5) ? (data_attr[6] ? 12'h0CC : 12'h0FF)
		: (data_attr[2:0]==6) ? (data_attr[6] ? 12'hCC0 : 12'hFF0)
		: (data_attr[2:0]==7) ? (data_attr[6] ? 12'hCCC : 12'hFFF)
		: {8'b0};
	 
	 	 assign color_paper=
		  (data_attr[5:3]==0) ? (data_attr[6] ? 12'h000 : 12'h000)
		: (data_attr[5:3]==1) ? (data_attr[6] ? 12'h00C : 12'h00F)
		: (data_attr[5:3]==2) ? (data_attr[6] ? 12'hC00 : 12'hF00)
		: (data_attr[5:3]==3) ? (data_attr[6] ? 12'hC0C : 12'hF0F)
		: (data_attr[5:3]==4) ? (data_attr[6] ? 12'h0C0 : 12'h0F0)
		: (data_attr[5:3]==5) ? (data_attr[6] ? 12'h0CC : 12'h0FF)
		: (data_attr[5:3]==6) ? (data_attr[6] ? 12'hCC0 : 12'hFF0)
		: (data_attr[5:3]==7) ? (data_attr[6] ? 12'hCCC : 12'hFFF)
		: {8'b0};

	 assign o_r=(vga_blank==1) ? {4'b0} : ((data_attr[7] ? (o_bit ^ vs_counter[5]) : o_bit) ? color_ink[11:8] : color_paper[11:8]);
	 assign o_g=(vga_blank==1) ? {4'b0} : ((data_attr[7] ? (o_bit ^ vs_counter[5]) : o_bit) ? color_ink[7:4] : color_paper[7:4]);
	 assign o_b=(vga_blank==1) ? {4'b0} : ((data_attr[7] ? (o_bit ^ vs_counter[5]) : o_bit) ? color_ink[3:0] : color_paper[3:0]);

	 wire bit4_tick,bit0_tick,bit26_tick;
	 
	 assign bit_tick=bit_num[0];

	 assign bit26_tick=(bit_num==2 || bit_num==6);
	 assign bit4_tick=(bit_num==4);
	 assign bit0_tick=(bit_num==0);
	 
	 //sekwencja do sprawdzenia: 
	 //bit2 - adres do obszaru pixeli (addr_reg). 
	 //bit4 - odczyt z pamici do tymczasowego rejestru pixeli (data_reg_tmp)
	 //bit6 - adres do obszaru atrybutw (addr_attr_reg)
	 //bit0 - odczyt z pamici do rejestru atrybutw (data_attr_reg), przepianie rejestru tymczasowego pixeli (data_reg_tmp) do rejestru pixeli (data_reg)
	 	 		
	// Atrybuty zaczynaj si od z800, a 1800 to offset od 4000 (pocztek 16k bloku pamici). 
	assign addr_wire=(bit_num>=1 && bit_num<=4) ? 
		{vga_next_sy_sh[7:6],vga_next_sy_sh[2:0],vga_next_sy_sh[5:3],next_byte_num_sh[4:0]} 
		: (13'h1800+{3'b0,vga_next_sy_sh[7:3],next_byte_num_sh[4:0]});
				
	// zatrzask dla adresu odczytu z pamici (pixele 2, atrybuty 6)
	always @(posedge bit26_tick)
	begin
		addr_reg<=addr_wire;
	end

   // zatrzask dla danch z pamici do rejestru tymczasowego (pixele)
	always @(posedge bit4_tick)
	begin
		//data_reg_tmp<=addr_reg[7:0]; //8'b00111110; //vga_mem_rec;
		data_reg_tmp<=vga_mem_rec;
	end

	 // odczyt z pamici (od 2 do 0 bitu do wystarczajco duo czasu, 1 bit to byo za mao)
	 // pixele (z rejestru tymczasowego) i atrybuty z pamici
	always @(posedge bit0_tick)
	begin
		data_reg<=data_reg_tmp;
		data_attr_reg<=vga_mem_rec;
	end
	
	always @(posedge vga_vs or posedge rst_pos)
	 begin
		if(rst_pos )
			vs_counter<=0;
		else
			if(vs_counter<60) 
				vs_counter<=vs_counter+1;
			else
				vs_counter<=0; // co ok. 1 sekund
	 end
	
	 
	 assign o_vga_hs=vga_hs;
	 assign o_vga_vs=vga_vs;
	 
	 vga_control vga_inst (
	 .clk25(clk_vga),
	 .rst(rst_pos),
	 .vsync(vga_vs),
	 .hsync(vga_hs),
	 .x(vga_x),
	 .y(vga_y),
	 .sx(vga_sx),
	 .sy(vga_sy),
	 .sx_counter_n(sx_cnt),
	 .sy_counter_n(sy_cnt),
	 .blank(vga_blank),
	 .blank_n(vga_blank_next),
	 .sx_counter(sx_counter),
	 .sy_counter(sy_counter),
	 .bit_num(bit_num),
	 .bit_num_n(bit_num_n),
	 .byte_num(byte_num),
	 .byte_num_n(byte_num_n),
	 .next_byte_num(next_byte_num),
	 .next_byte_num_n(next_byte_num_n),
	 .next_y(vga_next_y),
	 .next_sy(vga_next_sy)
	 );
	 
	wire swtick,rst_deb,sw_up,sw_down;
	wire dummy_led01;	 

	 wire [6:0] btn_counter;
	 //assign LED[6:0]=btn_counter;
	 
	 wire memWEpos;
	 wire memWEvaddr,memWEv;
	 
	 reg memWEv_reg;
	 
	 assign memWEv=memWEv_reg;
	 	 
	 assign memWEpos=~(in_mreq_r/* | in_wr*/);
	 //assign memWEvaddr=memWEpos & (ADDRin_w>=16'h4000 && ADDRin_w<=16'h5AFF);
	 //assign memWEv=memWEvaddr & (memwe_counter>=10 && memwe_counter<=11);
	 
	 reg en_d,en_al,en_ah;

	 assign o_en_d=~en_d;
	 assign o_en_ah=~en_ah;
	 assign o_en_al=~en_al;
	 
	 reg [7:0] Lin_r;
	 reg [7:0] DATAin_reg;
	 reg [7:0] ADDRinH_reg;
	 reg [7:0] ADDRinL_reg;
	 reg in_mreq_r,in_wr_r;

	 wire [15:0] ADDRin_w;
	 assign ADDRin_w={ADDRinH_reg[7:0],ADDRinL_reg[7:0]};	 
	 	 
	always @ (posedge clk_master or negedge rst)
	begin
		if(~rst)
		begin
			counter<=0;
		end	
		else
		begin
			if(memWEpos)
			begin
				case (memwe_counter)
				1: begin 
						en_al<=1;
					end
				4: begin 
						ADDRinL_reg[7:0]<=Lin_r[7:0];
					end
				5: begin
						en_al<=0; 
						en_ah<=1;
					end
				8: begin
						ADDRinH_reg[7:0]<=Lin_r[7:0];
					end
				9: begin
						en_ah<=0;
						en_d<=1;
					end
				12: begin
						DATAin_reg[7:0]<=Lin_r[7:0];
					end
				13: begin
						en_d<=0;
					end
				endcase

				if(memwe_counter>=15 && ~in_wr_r && ADDRin_w>=16'h4000 && ADDRin_w<=16'h5AFF)
				begin
				// progi 4 i 8 dobrane eksperymentalnie
					memWEv_reg<=(memwe_counter_wr>=4 && memwe_counter_wr<=8) ? 1:0;
					memwe_counter_wr<=memwe_counter_wr+1;
				end				
				memwe_counter<=memwe_counter+1;
			end
			else
			begin
				memwe_counter<=0;
				memwe_counter_wr<=0;
				en_d<=0;
				en_ah<=0;
				en_al<=0;
				memWEv_reg<=0;
				DATAin_reg[7:0]<=8'b0;
				ADDRinH_reg[7:0]<=8'b0;
				ADDRinL_reg[7:0]<=8'b0;
			end
			counter<=counter+1;
			// zapisywanie wejsc do rejestrow co zbocze zegara poprawia stabilnosc
			Lin_r<=Lin;
			in_mreq_r<=in_mreq;
			in_wr_r<=in_wr;
		end
	end	
	 
	 	 	
	ram16k z80ram1 (
	  .clka(clk_master), // input clka
	  .ena(1'b1), // input ena
	  .wea(memWEv_reg), // input [0 : 0] wea
	  .addra(ADDRin_w[12:0]), // input [13 : 0] addra
	  .dina(DATAin_reg), // input [7 : 0] dina
	  .clkb(clk_master),
	  .web(1'b0),
	  .addrb(addr_reg),
	  .doutb(vga_mem_rec)
	);				
	
	// testowo
	//assign LED[7:4]=DATAv[7:4];	
	assign LED[4:0]=memwe_counter[4:0];
	assign LED[6:5]=2'b0;
	assign LED[7]=vs_counter[5];
				
	// przyciski i zegary dla stabilizacji przyciskw
	button_counter #(.N(7)) but_counter(.clk(clk_master),.rst_neg(rst),.but_up(sw_up),.but_down(sw_down),.b_counter(btn_counter));		
	
	switch_debounce_clock #(.N(20)) sw_debounce_clk (.swclock(clk_master),.swtickClk(swtick),.swtickLED(dummy_led01));
	
	switch_debounce sw_deb_rst (.swclock(clk_master),.swtick(swtick),.sw(SW1),.dbsw(rst),.dbsw_neg(rst_pos));
	switch_debounce sw_deb_up (.swclock(clk_master),.swtick(swtick),.sw(SW2),.dbsw_neg(sw_up));
	switch_debounce sw_deb_down (.swclock(clk_master),.swtick(swtick),.sw(SW3),.dbsw_neg(sw_down));
	switch_debounce sw_deb_key (.swclock(clk_master),.swtick(swtick),.sw(SW4),.dbsw_neg(key_down));

	
endmodule
