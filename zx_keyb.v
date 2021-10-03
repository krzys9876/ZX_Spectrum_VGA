`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:48:22 11/16/2018 
// Design Name: 
// Module Name:    zx_keyb 
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
module zx_keyb(
	input [7:0] addr,
	input [6:0] code,
	input en,
	input key_flag,
	output [7:0] dout
    );
	 
	 //assign dout=8'b1111110;
	 wire [7:0] dout_key,dout_keyL,dout_keyR,dout_sym,dout_caps;
	 
	 wire [3:0] addrL,addrR;
	 
	 // przy sprawdzaniu jednej linii liczy siê tylko po³owa adresu, pozosta³a nie ma znaczenia
	 // ten mechanizm wykorzystuje np. Knight Lore, czyta z adresu BD, czyli jednoczeœnie FD i BF, ca³y wiersz klawiatury
	 assign addrL[3:0]=addr[3:0]; // lewa po³owa klawiatury (pod³¹czone m³odsze 4 bity)
	 assign addrR[3:0]=addr[7:4]; // prawa po³owa klawiatury (pod³¹czone starsze 4 bity)
	 
	 
/*	 assign dout_key=(~en | ~key_flag) ? 8'b11111111 :
		//(addr==8'hF7 & code==7'h01) ? 8'b11111110 : 
		//(addr==8'hF7 & code==7'h02) ? 8'b11111101 : 
(addrL==4'hB & code==7'h1E) ? 8'b11111110 : 
(addrL==4'hB & code==7'h24) ? 8'b11111101 : 
(addrL==4'hB & code==7'h12) ? 8'b11111011 : 
(addrL==4'hB & code==7'h1F) ? 8'b11110111 : 
(addrL==4'hB & code==7'h21) ? 8'b11101111 : 
(addrR==4'hD & code==7'h26) ? 8'b11101111 : 
(addrR==4'hD & code==7'h22) ? 8'b11110111 : 
(addrR==4'hD & code==7'h16) ? 8'b11111011 : 
(addrR==4'hD & code==7'h1C) ? 8'b11111101 : 
(addrR==4'hD & code==7'h1D) ? 8'b11111110 : 
(addrL==4'hD & code==7'h0E) ? 8'b11111110 : 
(addrL==4'hD & code==7'h20) ? 8'b11111101 : 
(addrL==4'hD & code==7'h11) ? 8'b11111011 : 
(addrL==4'hD & code==7'h13) ? 8'b11110111 : 
(addrL==4'hD & code==7'h14) ? 8'b11101111 : 
(addrR==4'hF & code==7'h15) ? 8'b11101111 : 
(addrR==4'hF & code==7'h17) ? 8'b11110111 : 
(addrR==4'hF & code==7'h18) ? 8'b11111011 : 
(addrR==4'hF & code==7'h19) ? 8'b11111101 : 
(addrL==4'hE & code==7'h27) ? 8'b11111101 : 
(addrL==4'hE & code==7'h25) ? 8'b11111011 : 
(addrL==4'hE & code==7'h10) ? 8'b11110111 : 
(addrL==4'hE & code==7'h23) ? 8'b11101111 : 
(addrR==4'h7 & code==7'h0F) ? 8'b11101111 : 
(addrR==4'h7 & code==7'h1B) ? 8'b11110111 : 
(addrR==4'h7 & code==7'h1A) ? 8'b11111011 : 
(addrL==4'h7 & code==7'h01) ? 8'b11111110 : 
(addrL==4'h7 & code==7'h02) ? 8'b11111101 : 
(addrL==4'h7 & code==7'h03) ? 8'b11111011 : 
(addrL==4'h7 & code==7'h04) ? 8'b11110111 : 
(addrL==4'h7 & code==7'h05) ? 8'b11101111 : 
(addrR==4'hE & code==7'h06) ? 8'b11101111 : 
(addrR==4'hE & code==7'h07) ? 8'b11110111 : 
(addrR==4'hE & code==7'h08) ? 8'b11111011 : 
(addrR==4'hE & code==7'h09) ? 8'b11111101 : 
(addrR==4'hE & code==7'h00) ? 8'b11111110 : 
(addrL==4'hE & code==7'h0D) ? 8'b11111110 : 
(addrR==4'h7 & code==7'h0C) ? 8'b11111101 : 
(addrR==4'hB & code==7'h0B) ? 8'b11111110 : 
(addrR==4'h7 & code==7'h0A) ? 8'b11111110 : 
//SYM
(addrR==4'hB & code==7'h30) ? 8'b11111101 : 
(addrR==4'hD & code==7'h31) ? 8'b11111110 : 
(addrL==4'hD & code==7'h32) ? 8'b11110111 : 
(addrR==4'hB & code==7'h33) ? 8'b11111011 : 
(addrR==4'hB & code==7'h34) ? 8'b11110111 : 
//CAPS
(addrR==4'hE & code==7'h40) ? 8'b11111110 : 
(addrR==4'h7 & code==7'h41) ? 8'b11111110 : 
		8'b11111111;
*/
/*
assign dout_keyL=(~en | ~key_flag) ? 8'b11111111 :
		//(addr==8'hF7 & code==7'h01) ? 8'b11111110 : 
		//(addr==8'hF7 & code==7'h02) ? 8'b11111101 : 
(addrL==4'hB & code==7'h1E) ? 8'b11111110 : 
(addrL==4'hB & code==7'h24) ? 8'b11111101 : 
(addrL==4'hB & code==7'h12) ? 8'b11111011 : 
(addrL==4'hB & code==7'h1F) ? 8'b11110111 : 
(addrL==4'hB & code==7'h21) ? 8'b11101111 : 
(addrL==4'hD & code==7'h0E) ? 8'b11111110 : 
(addrL==4'hD & code==7'h20) ? 8'b11111101 : 
(addrL==4'hD & code==7'h11) ? 8'b11111011 : 
(addrL==4'hD & code==7'h13) ? 8'b11110111 : 
(addrL==4'hD & code==7'h14) ? 8'b11101111 : 
(addrL==4'hE & code==7'h27) ? 8'b11111101 : 
(addrL==4'hE & code==7'h25) ? 8'b11111011 : 
(addrL==4'hE & code==7'h10) ? 8'b11110111 : 
(addrL==4'hE & code==7'h23) ? 8'b11101111 : 
(addrL==4'h7 & code==7'h01) ? 8'b11111110 : 
(addrL==4'h7 & code==7'h02) ? 8'b11111101 : 
(addrL==4'h7 & code==7'h03) ? 8'b11111011 : 
(addrL==4'h7 & code==7'h04) ? 8'b11110111 : 
(addrL==4'h7 & code==7'h05) ? 8'b11101111 : 
(addrL==4'hE & code==7'h0D) ? 8'b11111110 : 
//SYM
(addrL==4'hD & code==7'h32) ? 8'b11110111 : 
//CAPS
		8'b11111111;		
		
		assign dout_keyR=(~en | ~key_flag) ? 8'b11111111 :
		//(addr==8'hF7 & code==7'h01) ? 8'b11111110 : 
		//(addr==8'hF7 & code==7'h02) ? 8'b11111101 : 
(addrR==4'hD & code==7'h26) ? 8'b11101111 : 
(addrR==4'hD & code==7'h22) ? 8'b11110111 : 
(addrR==4'hD & code==7'h16) ? 8'b11111011 : 
(addrR==4'hD & code==7'h1C) ? 8'b11111101 : 
(addrR==4'hD & code==7'h1D) ? 8'b11111110 : 
(addrR==4'hB & code==7'h15) ? 8'b11101111 : 
(addrR==4'hB & code==7'h17) ? 8'b11110111 : 
(addrR==4'hB & code==7'h18) ? 8'b11111011 : 
(addrR==4'hB & code==7'h19) ? 8'b11111101 : 
(addrR==4'h7 & code==7'h0F) ? 8'b11101111 : 
(addrR==4'h7 & code==7'h1B) ? 8'b11110111 : 
(addrR==4'h7 & code==7'h1A) ? 8'b11111011 : 
(addrR==4'hE & code==7'h06) ? 8'b11101111 : 
(addrR==4'hE & code==7'h07) ? 8'b11110111 : 
(addrR==4'hE & code==7'h08) ? 8'b11111011 : 
(addrR==4'hE & code==7'h09) ? 8'b11111101 : 
(addrR==4'hE & code==7'h00) ? 8'b11111110 : 
(addrR==4'h7 & code==7'h0C) ? 8'b11111101 : 
(addrR==4'hB & code==7'h0B) ? 8'b11111110 : 
(addrR==4'h7 & code==7'h0A) ? 8'b11111110 : 
//SYM
(addrR==4'hB & code==7'h30) ? 8'b11111101 : 
(addrR==4'hD & code==7'h31) ? 8'b11111110 : 
(addrR==4'hB & code==7'h33) ? 8'b11111011 : 
(addrR==4'hB & code==7'h34) ? 8'b11110111 : 
//CAPS
(addrR==4'hE & code==7'h40) ? 8'b11111110 : 
(addrR==4'h7 & code==7'h41) ? 8'b11111110 : 
		8'b11111111;
*/

	assign dout_key[0]=(~en | ~key_flag) | ~((~addr[3] & (code==7'h01)) | (~addr[2] & (code==7'h1E)) | (~addr[1] & (code==7'h0E)) | (~addr[0] & (code==7'h0D)) | (~addr[4] & (code==7'h00 | code==7'h40)) | (~addr[5] & (code==7'h1D | code==7'h31)) | (~addr[6] & (code==7'h0B)) | (~addr[7] & (code==7'h0A | code==7'h41)));
	assign dout_key[1]=(~en | ~key_flag) | ~((~addr[3] & (code==7'h02)) | (~addr[2] & (code==7'h24)) | (~addr[1] & (code==7'h20)) | (~addr[0] & (code==7'h27)) | (~addr[4] & (code==7'h09)) | (~addr[5] & (code==7'h1C)) | (~addr[6] & (code==7'h19 | code==7'h30)) | (~addr[7] & (code==7'h0C)));
	assign dout_key[2]=(~en | ~key_flag) | ~((~addr[3] & (code==7'h03)) | (~addr[2] & (code==7'h12)) | (~addr[1] & (code==7'h11)) | (~addr[0] & (code==7'h25)) | (~addr[4] & (code==7'h08)) | (~addr[5] & (code==7'h16)) | (~addr[6] & (code==7'h18 | code==7'h33)) | (~addr[7] & (code==7'h1A)));
	assign dout_key[3]=(~en | ~key_flag) | ~((~addr[3] & (code==7'h04)) | (~addr[2] & (code==7'h1F)) | (~addr[1] & (code==7'h13 | code==7'h32)) | (~addr[0] & (code==7'h10)) | (~addr[4] & (code==7'h07)) | (~addr[5] & (code==7'h22)) | (~addr[6] & (code==7'h17 | code==7'h34)) | (~addr[7] & (code==7'h1B)));
	assign dout_key[4]=(~en | ~key_flag) | ~((~addr[3] & (code==7'h05)) | (~addr[2] & (code==7'h21)) | (~addr[1] & (code==7'h14)) | (~addr[0] & (code==7'h23)) | (~addr[4] & (code==7'h06)) | (~addr[5] & (code==7'h26)) | (~addr[6] & (code==7'h15)) | (~addr[7] & (code==7'h0F)));
	assign dout_key[7:5]=3'b111;

		
		//assign dout_key=dout_keyL & dout_keyR;
		
		assign dout_sym=dout_key & (
			(~addr[7] & code[6:4]==3'h3) ? 8'b11111101 :
			8'b11111111);
			;
			
		assign dout_caps=dout_sym & (
			(~addr[0] & code[6:4]==3'h4) ? 8'b11111110 :
			8'b11111111);
			;
			
		assign dout=dout_caps;


endmodule
