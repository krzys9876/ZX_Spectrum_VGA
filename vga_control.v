`timescale 1ns / 1ps

module vga_control(
    input clk25,
    input rst,
    output reg hsync, vsync,
	 output hsync_n, vsync_n,
	 // wartoœci pierwotne
    output reg [9:0] y,
	 output reg [9:0] x,
    output [9:0] y_n, // n = "next"
	 output [9:0] x_n,
	 output reg blank,
	 output blank_n,
	 // wartoœci skalowane
	 output reg [9:0] sy,
	 output reg [9:0] sx,
	 output [9:0] sy_n, 
	 output [9:0] sx_n,
	 output reg [4:0] sx_counter,
	 output reg [4:0] sy_counter,
	 output [4:0] sx_counter_n,
	 output [4:0] sy_counter_n,
	 output reg [2:0] bit_num,
	 output [2:0] bit_num_n,
	 //output reg bit_tick,
	 output reg [7:0] byte_num,
	 output [7:0] byte_num_n,
	 output reg [7:0] next_byte_num,
	 output [7:0] next_byte_num_n,
	 output reg [9:0] next_y,
	 output [9:0] next_y_n,
	 output reg [9:0] next_sy,
	 output [9:0] next_sy_n
	 );
	 



always@(posedge clk25 or posedge rst)
begin
	if (rst)
	begin
		x<=0;
		y<=0;
		hsync<=1;
		vsync<=1;
		blank<=0;
		sx_counter<=0;
		sy_counter<=0;		
		sx<=0;
		sy<=0;
		bit_num<=0;
		byte_num<=0;
		next_byte_num<=0;
		next_y<=0;
		next_sy<=0;
		//bit_tick<=0;
	end
	else
	begin
		x<=x_n;
		y<=y_n;
		hsync<=hsync_n;
		vsync<=vsync_n;
		blank<=blank_n;
		sx_counter<=sx_counter_n;
		sy_counter<=sy_counter_n;	
		sx<=sx_n;
		sy<=sy_n;		
		bit_num<=bit_num_n;
		byte_num<=byte_num_n;
		next_byte_num<=next_byte_num_n;
		next_y<=next_y_n;
		next_sy<=next_sy_n;
	end
end

parameter MAX_X=800;
parameter MAX_Y=525; // UWAGA: liczna nieparzysta!
parameter BITS=8;
parameter SCALE_X = 2 ; // skala
parameter SCALE_Y = 2 ; // skala

//col counter [0->799]
assign x_n=(x==MAX_X-1) ? 0 : x+1;
assign sx_counter_n=(x==MAX_X-1) ? 0 : ((sx_counter==SCALE_X-1) ? 0 : sx_counter+1 );
assign sx_n=(x==MAX_X-1) ? 0 :((sx_counter==SCALE_X-1) ? sx+1 : sx );
assign bit_num_n=(x==MAX_X-1) ? 0 : ((sx_counter==SCALE_X-1) ? bit_num+1 : bit_num); // w pêtli 0..7, bo tylko 3 bity
assign byte_num_n=(x==MAX_X-1) ? 0 :((sx_counter==SCALE_X-1 && bit_num==BITS-1) ? byte_num+1 : byte_num);
assign next_byte_num_n=(x==MAX_X-1-BITS*SCALE_X) ? 0 :((sx_counter==SCALE_X-1 && bit_num==BITS-1) ? next_byte_num+1 : next_byte_num);


//row counter [0->524]
assign y_n=(x==MAX_X-1) ? ((y==MAX_Y-1) ? 0 : y+1) : y;
assign sy_counter_n=(y>=MAX_Y-2) ? 0 : ((x==MAX_X-1) ? ((sy_counter==SCALE_Y-1) ? 0 : sy_counter+1) : sy_counter); //y_n[4:0];
assign sy_n=(x==MAX_X-1) ? ((y>=MAX_Y-2) ? 0 : ((sy_counter==SCALE_Y-1) ? sy+1 : sy)) : sy;
assign next_y_n=(x==MAX_X-1-BITS*SCALE_X) ? ((y==MAX_Y-1) ? 0 : next_y+1) : next_y;
assign next_sy_n=(x==MAX_X-1-BITS*SCALE_X) ? ((y>=MAX_Y-2) ? 0 : ((sy_counter==SCALE_Y-1) ? next_sy+1 : next_sy)) : next_sy;


// hsync pulse generation
assign hsync_n=(x>=655 && x<=750) ? 0 : 1;

//vsync pulse generation
assign vsync_n=(y>=489 && y<=490) ? 0 : 1;

// blank outside visible area
assign blank_n=(x>=639 || y>=479) ? 1 : 0;

endmodule
