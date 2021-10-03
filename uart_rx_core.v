`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:50:39 11/04/2018 
// Design Name: 
// Module Name:    uart_rx_core 
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
module uart_rx_core(
	input clk,reset,baudgen_clk,baudgen_tick,rxIN,readD,readC,
	output [7:0] rxbyte,
	output ready,data_avail
    );

	 localparam [1:0]
		rx_idle = 2'b00,
		rx_start = 2'b01,
		rx_data = 2'b10,
		rx_stop = 2'b11;
		
	//localparam 
	//	waiting = 1'b0;
	//	reading = 1'b1;
	
	reg [1:0] rx_state,rx_state_next;
	reg [3:0] s_reg,s_next; // tick
	reg [2:0] n_reg,n_next; // bit
	reg [7:0] b_reg,b_next; // received byte - miga w czasie odczytu!
	
	reg data_avail_reg,data_avail_next; // konieczne migniêcie pod koniec odczytu
	
	assign ready=(rx_state==rx_idle) ? 1'b1 : 1'b0;
	assign  rxbyte=b_reg;
	assign data_avail=data_avail_reg;
	
	always @(posedge clk,posedge reset)
	begin
		if(reset)
		begin
			rx_state<=rx_idle;
			s_reg<=0;
			n_reg<=0;
			b_reg<=0;
			data_avail_reg<=0;
			
		end
		else
		begin
			rx_state<=rx_state_next;
			s_reg<=s_next;
			n_reg<=n_next;
			b_reg<=b_next;
			data_avail_reg<=data_avail_next;
		end
	end
	
	always @*
	begin
		rx_state_next=rx_state;
		s_next=s_reg;
		n_next=n_reg;
		b_next=b_reg;
		data_avail_next=data_avail_reg;
				
		case (rx_state)
			rx_idle: begin
						if(~rxIN)
						begin
							rx_state_next=rx_start;
							s_next=0;
							 
						end
					 end
			rx_start: begin
						if(baudgen_tick)
                            if(s_reg==7) // start_bit - mid
                            begin
                                rx_state_next=rx_data;
                                s_next=0;
                                n_next=0;
										  data_avail_next=0;
                            end
                            else
                            begin
                                s_next=s_reg+1;
                            end
					 end
			rx_data:	begin
						if(baudgen_tick)
                            if(s_reg==15) // data bit - mid
                            begin
                                s_next=0;
                                b_next={rxIN,b_reg[7:1]}; // bit dok³adany z lewej strony
                                if(n_reg==7)
                                begin
                                    rx_state_next=rx_stop;                                    
                                end
                                else
                                begin
                                    n_next=n_reg+1;
                                end
                            end
                            else
                            begin
                                s_next=s_reg+1;
                            end
					 end 
			rx_stop:  begin
					   if(baudgen_tick)
                           if(s_reg==15) // stop bit - end (dope³nienie, choæ mo¿e niepotrzebne, wystarczy³oby 15)
                            begin
                                rx_state_next=rx_idle;
                                data_avail_next=1;
                            end
                            else
                            begin
                                s_next=s_reg+1;
                            end
                         end	
		endcase		

							
	end


endmodule
