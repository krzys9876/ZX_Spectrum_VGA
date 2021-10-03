`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:13:42 11/09/2018 
// Design Name: 
// Module Name:    ticker 
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
module ticker(
	input clk,
	input reset,
	input signal,
	input [7:0] delay,
	input [7:0] length,
	output tick,
	output [7:0] audit
    );
	 
	reg tick_reg,tick_next;
	
	reg enabled, enabled_next;
	
	reg [7:0] counter,counter_next;
	reg [7:0] t_counter,t_counter_next;
	
	assign tick=tick_reg;
	
	//assign audit[1:0]=state_reg;
	assign audit[7:0]=counter[7:0];
			
	always @(posedge clk, posedge reset)
	begin
		if(reset)
		begin
			counter<=0;
			t_counter<=0;
			tick_reg<=0;
			enabled<=1;
		end
		else
		begin
			counter<=counter_next;
			t_counter<=t_counter_next;
			tick_reg<=tick_next;
			enabled<=enabled_next;
		end
	end
	
	always @*
	begin
		counter_next=counter;
		tick_next=tick_reg;
		enabled_next=enabled;
				
		case (enabled)
			1: begin
					if(delay==0)
					begin
					   if(signal)
					   begin
					       tick_next=1;						       				       
                           counter_next=0;
                           enabled_next=0;
                           t_counter_next=length;                       
                       end
                    end
                    else
					if(counter==0)
					begin
						if(signal)
						begin
							counter_next=counter+1;
						end
					end
					else
					if(counter==delay)
					begin
						tick_next=1;
						counter_next=0;
						enabled_next=0;
						t_counter_next=length;
					end
					else
						counter_next=counter+1;
				end
			0: begin
					if(t_counter==0)
					begin
					   tick_next=0;
					   if(~signal)
                       begin
                          enabled_next=1;
                       end
                    end
					else
					   t_counter_next=t_counter-1;                               					
				end
		endcase
					
	end

endmodule
