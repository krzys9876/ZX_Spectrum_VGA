`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:14:55 11/05/2018 
// Design Name: 
// Module Name:    tx_core 
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
module uart_tx_core(
	input clk,reset,baudgen_clk,baudgen_tick,txstart,
	input [7:0] txbyte,
	output txOUT,
	output ready
    );
	 
	 localparam [1:0]
		tx_idle = 2'b00,
		tx_start = 2'b01,
		tx_data = 2'b10,
		tx_stop = 2'b11;
	
	reg [1:0] tx_state,tx_state_next;
	reg [4:0] s_reg,s_next; // tick
	reg [2:0] n_reg,n_next; // bit
	reg [7:0] b_reg,b_next; // received byte - miga w czasie odczytu!
	reg tx_reg,tx_next;
	
	reg tx_avail,tx_avail_next;
	
	assign ready=(tx_state==tx_idle) ? 1'b1 : 1'b0;
	assign txOUT=tx_reg;
	
	always @(posedge clk,posedge reset)
	begin
		if(reset)
		begin
			tx_state<=tx_idle;
			s_reg<=0;
			n_reg<=0;
			b_reg<=0;
			tx_reg<=1'b1;
			tx_avail<=1'b1;
		end
		else
		begin
			tx_state<=tx_state_next;
			s_reg<=s_next;
			n_reg<=n_next;
			b_reg<=b_next;
			tx_reg<=tx_next;
			tx_avail<=tx_avail_next;
		end
	end	 


	always @*
	begin
		tx_state_next=tx_state;
		s_next=s_reg;
		n_next=n_reg;
		b_next=b_reg;
		tx_next=tx_reg;
		tx_avail_next=tx_avail;
		
		case (tx_state)
			tx_idle: 
					begin
						tx_next=1'b1; // teoretycznie niepotrzebne, sprawdziæ, czy nie powinno to byæ w "if"
						if(txstart & tx_avail)
						begin
							tx_state_next=tx_start;
							s_next=0;
							b_next=txbyte;
							tx_avail_next=1'b0;
						end
						else
							if(~txstart)
								tx_avail_next=1'b1; // reset flagi - tylko jak sygna³ START bêdzie = 0 w czasie tx_idle
					end
			tx_start: 
					begin
						tx_next=1'b0; // teoretycznie niepotrzebne, sprawdziæ, czy nie powinno to byæ w "if"
						if(baudgen_tick)
                            if(s_reg==15)
                            begin
                                tx_state_next=tx_data;
                                s_next=0;
                                n_next=0;
                            end
                            else
                            begin
                                s_next=s_reg+1;
                            end
					end
			tx_data:
					begin
						tx_next=b_reg[0];
						if(baudgen_tick)
                            if(s_reg==15)
                            begin
                                s_next=0;
                                b_next=b_reg >> 1;
                                if(n_reg==7)
                                    tx_state_next=tx_stop;								
                                else
                                    n_next=n_reg+1;
                            end
                            else
                            begin
                                s_next=s_reg+1;
                            end
					end
			tx_stop: 
					begin
						tx_next=1'b1; // teoretycznie niepotrzebne, sprawdziæ, czy nie powinno to byæ w "if"
                        if(baudgen_tick)
                            if(s_reg==15)
                            begin
                                tx_state_next=tx_idle;
                            end
                            else
                            begin
                                s_next=s_reg+1;
                            end
					end
		endcase
	end
	

endmodule
