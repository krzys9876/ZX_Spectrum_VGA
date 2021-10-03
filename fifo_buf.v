`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:04:05 11/08/2018 
// Design Name: 
// Module Name:    fifo_buf 
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
module fifo_buf
	# (parameter B=8, // number of bits in a word
		W=4 // number of address bits
		)
	(
	input wire clk, reset,
	input wire rd, wr,
	input wire [B-1:0] w_data,
	output wire empty, full,
	output wire [B-1:0] r_data,
	output [W-1:0] w_ptr,r_ptr
	);

	// signal declaration
	reg [B-1:0] array_reg [2**W-1:0] ; // register array
	reg [W-1:0] w_ptr_reg, w_ptr_next , w_ptr_succ;
	reg [W-1:0] r_ptr_reg ,r_ptr_next , r_ptr_succ;
	reg full_reg, empty_reg, full_next, empty_next;
	
	assign w_ptr=w_ptr_reg;
	assign r_ptr=r_ptr_reg;

	reg rd_av_reg,rd_av_next;
	//reg rd_tick_reg;

	wire wr_en;

	// body
	// register file write operation
	always @(posedge clk)
		if (wr_en)
			array_reg[w_ptr_reg] <= w_data;
		
		// register file read operation
		assign r_data = array_reg [r_ptr_reg-1] ;
		// write enabled only when FIFO is not full
		assign wr_en = wr & ~full_reg;
		
		
		
		// fifo control logic
		// register for read and write pointers
		always @ ( posedge clk, posedge reset)
			if (reset)
			begin
				w_ptr_reg <= 0;
				r_ptr_reg <= 0;
				full_reg <= 1'b0;
				empty_reg <= 1'b1;
				rd_av_reg<=1'b1;
			end
			else
			begin
				w_ptr_reg <= w_ptr_next ;
				r_ptr_reg <= r_ptr_next;
				full_reg <= full_next;
				empty_reg <= empty_next ;
				rd_av_reg<=rd_av_next;
			end

// next-state logic for read and write pointers
	always @*
	begin
		// successive pointer values
		w_ptr_succ = w_ptr_reg + 1;
		r_ptr_succ = r_ptr_reg + 1;
		// default: keep old values
		w_ptr_next = w_ptr_reg;
		r_ptr_next = r_ptr_reg;
		full_next = full_reg;
		empty_next = empty_reg;
		rd_av_next=rd_av_reg;
		
		//rd_tick_reg=0;
		
		if(rd)
			rd_av_next=0; // blokada odczytów
		else
			rd_av_next=1;
		
		if(rd)
		begin
			if (~empty_reg & rd_av_reg) // not empty
				begin
					r_ptr_next = r_ptr_succ ;
					full_next = 1'b0;
					if (r_ptr_succ==w_ptr_reg)
						empty_next = 1'b1;
				end
		end
		if(wr)
		begin
			if (~full_reg) // not full
				begin
					w_ptr_next = w_ptr_succ ;
					empty_next = 1'b0;
					if (w_ptr_succ==r_ptr_reg)
						full_next = 1'b1;
				end
		end
		
		/*case ({wr, rd})
			// 2'b00: no op
			2'b01: // read
				if (~empty_reg & rd_av_reg) // not empty
				begin
					r_ptr_next = r_ptr_succ ;
					full_next = 1'b0;
					if (r_ptr_succ==w_ptr_reg)
						empty_next = 1'b1;
				end
			2'b10: // write
				if (~full_reg) // not full
				begin
					w_ptr_next = w_ptr_succ ;
					empty_next = 1'b0;
					if (w_ptr_succ==r_ptr_reg)
						full_next = 1'b1;
				end
			2'b11: // write and read
				begin
					if(rd_av_reg)
					begin
						w_ptr_next = w_ptr_succ;
						r_ptr_next = r_ptr_succ ;
					end
				end
		endcase*/
	end

	// output
	assign full = full_reg;
	assign empty = empty_reg;

endmodule
