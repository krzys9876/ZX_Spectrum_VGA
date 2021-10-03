`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:10:10 10/30/2018 
// Design Name: 
// Module Name:    button_counter 
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
module button_counter
	#(parameter N=4)(
	input clk,rst_neg,but_up,but_down,
	output [N-1:0] b_counter
    );
	 
	 reg [N-1:0] cnt_reg,cnt_next;
	 
	 localparam [1:0]
		no_but=2'b00,
		but_dn_press=2'b01,
		but_up_press=2'b10
		;
		
	assign b_counter=cnt_reg;
		
	reg [2:0] but_state_reg,but_state_next;

	
	 always @ (posedge clk or negedge rst_neg)
	begin
		if(~rst_neg)
		begin
			cnt_reg<=0;
			but_state_reg<=no_but;
		end	
		else
		begin
			cnt_reg<=cnt_next;
			but_state_reg<=but_state_next;
		end
	end
	
	always @*
	begin
		but_state_next=but_state_reg;
		cnt_next=cnt_reg;
		case(but_state_reg)
			no_but:
				begin
					if(but_down)
						but_state_next=but_dn_press;
					else if(but_up)
						but_state_next=but_up_press;
				end
			but_dn_press:
				begin
					if(~but_down)
					begin
						but_state_next=no_but;
						cnt_next=cnt_reg-1;
					end
				end
			but_up_press:
				begin
					if(~but_up)
					begin
						but_state_next=no_but;
						cnt_next=cnt_reg+1;
					end
				end
			endcase
	end
	


endmodule
