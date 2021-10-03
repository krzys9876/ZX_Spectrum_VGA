`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:22:38 11/04/2018 
// Design Name: 
// Module Name:    mod_counter 
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
module mod_counter
	#(BITS=4,MOD=10)
(
	input clk,reset,
	output mod_tick,
	output [BITS-1:0] cnt,
	output mod_clk
    );
	 
	reg [BITS-1:0] counter;
	wire [BITS-1:0] counter_n;
	reg m_clk;
	 
	always@(posedge clk,posedge reset)
	begin
		if(reset)
		begin
			counter<=0;
			m_clk<=0;
		end
		else
		begin
			counter<=counter_n;
			m_clk<=(counter_n==0)? ~m_clk : m_clk;
		end
	end
	
	assign counter_n=(counter==MOD-1)? 0 : counter+1;
	assign mod_tick=(counter==MOD-1);
	assign cnt=counter;
	

	/*always@(posedge mod_tick)
	begin
		m_clk=~m_clk;
	end*/

	assign mod_clk=m_clk;

endmodule
