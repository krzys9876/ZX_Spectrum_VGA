`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:57:33 11/06/2018 
// Design Name: 
// Module Name:    uart 
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
module uart(
	input clk, // 100M
	input reset,//read,
	input rxIN,
    input read,write,
	input [7:0] datain,
	output baudgen_clk,buf_empty,buf_full,uart_avail,
	output [7:0] dataout,
	output txOUT,tx_ready,
	output [7:0] audit
    );
    
    
	 
	 wire baudgen_tick,rx_readD,rx_ready,rx_avail,wr_en;
	 
	 wire [7:0] baudgen_cnt;
	 wire [7:0] rx_byte;
	 //wire baudgen_clk;
	 // 8 ~= 7.3728M/57600/16
	 mod_counter #(.BITS(8),.MOD(8)) mod_cnt(.clk(clk),.reset(reset),.mod_tick(baudgen_tick),.cnt(baudgen_cnt),.mod_clk(baudgen_clk));
	 
	 uart_rx_core rx_core(.clk(clk),.reset(reset),.baudgen_clk(baudgen_clk),.baudgen_tick(baudgen_tick),.rxIN(rxIN),/*.readD(rx_readD),*/.rxbyte(rx_byte),.ready(rx_ready),.data_avail(rx_avail));
	 
	 wire [1:0] w_ptr,r_ptr;
	 
	 // bufor na BITS^2 bajtów
     fifo #(.BITS(8)) fifo_inst(.clk(clk),.reset(reset),.rd(read),.wr(rx_avail),.w_data(rx_byte),
        .empty(buf_empty),.full(buf_full),.r_data(dataout),.w_ptr(w_ptr),.r_ptr(r_ptr),.wr_en(wr_en));
    
    assign uart_avail=~buf_empty;
    
    wire tx_tick;
    
    ticker wr_tick_inst(.clk(clk),.reset(reset),.signal(write),.delay(0),.length(0),.tick(tx_tick));
    
    uart_tx_core tx_core(.clk(clk),.reset(reset),.baudgen_clk(baudgen_clk),.baudgen_tick(baudgen_tick),.txstart(tx_tick),
        .txbyte(datain),.txOUT(txOUT),.ready(tx_ready));
		  
	assign audit[7]=0;
	assign audit[6]=rx_avail;
	assign audit[5]=buf_full;	  
	assign audit[4]=buf_empty;	  
	assign audit[3:2]=w_ptr;
	assign audit[1:0]=r_ptr;



endmodule

/*module uart(
	input clk, // 100M
	input reset,//read,
	//input [7:0] datain,
	output baudgen_clk//,ready,data_avail,
	//output [7:0] dataout
    );
	 
	 wire baudgen_tick;	 
	 wire [7:0] baudgen_cnt;
	 //wire baudgen_clk;
	 // 54 ~= 100M/57600/16/2
	 mod_counter #(.BITS(6),.MOD(54)) mod_cnt(.clk(clk),.reset(reset),.mod_tick(baudgen_tick),.cnt(baudgen_cnt),.mod_clk(baudgen_clk));
	 



endmodule
*/