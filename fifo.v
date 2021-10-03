`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2018 15:00:39
// Design Name: 
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo #(BITS=8) (
    input wire clk, reset,
	input wire rd, wr,
	input wire [7:0] w_data,
	output wire empty, full,
	output wire [7:0] r_data,
	output [BITS-1:0] w_ptr,r_ptr,
	output wr_en
    );
    
    reg [7:0] array_reg [BITS**2-1:0] ; // register array
    reg [BITS-1:0] w_ptr_reg, w_ptr_next , w_ptr_succ; // actual write pointer (KR)
    reg [BITS-1:0] r_ptr_reg ,r_ptr_next , r_ptr_succ; // next read pointer
    wire [BITS-1:0] r_ptr_act; // actual read pointer
    
    reg full_reg, empty_reg, full_next, empty_next;
    
    
    wire rd_tick,wr_tick;
    
    ticker rd_tick_inst(.clk(clk),.reset(reset),.signal(rd),.delay(0),.length(0),.tick(rd_tick));
    ticker wr_tick_inst(.clk(clk),.reset(reset),.signal(wr),.delay(0),.length(0),.tick(wr_tick));
        
    assign w_ptr=w_ptr_reg;
    assign r_ptr=r_ptr_reg;
    
    //wire wr_en;
    assign wr_en = wr_tick & (~full_reg);
    
    always @(posedge clk)
        if (wr_en)
            array_reg[w_ptr_reg] <= w_data;
 
    // register file read operation
    assign r_ptr_act=r_ptr_reg-1;
    assign r_data = array_reg [r_ptr_act] ;
    // write enabled only when FIFO is not full
    
    
    // fifo control logic
    // register for read and write pointers
    always @ ( posedge clk, posedge reset)
    if (reset)
    begin
        w_ptr_reg <= 0;
        r_ptr_reg <= 0;
        full_reg <= 1'b0;
        empty_reg <= 1'b1;
    end
    else
    begin
        w_ptr_reg <= w_ptr_next ;
        r_ptr_reg <= r_ptr_next;
        full_reg <= full_next;
        empty_reg <= empty_next ;
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
            
            case ({wr_tick, rd_tick})
                // 2'b00: no op
                2'b01: // read
                    if (~empty_reg) // not empty
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
                        w_ptr_next = w_ptr_succ;
                        r_ptr_next = r_ptr_succ ;
                    end
            endcase
        end
    
        // output
        assign full = full_reg;
        assign empty = empty_reg;

    
endmodule
