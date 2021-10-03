`timescale 1ns / 1ps

module switch_debounce(
	input swclock,
	input swtick,
	input sw,
	output dirsw,dirsw_neg,
	output reg dbsw,
	output dbsw_neg,
	output [2:0] state
    );

	localparam [2:0]
		zero=3'b000,
		wait1_1=3'b001,
		wait1_2=3'b010,
		wait1_3=3'b011,
		one=3'b100,
		wait0_1=3'b101,
		wait0_2=3'b110,
		wait0_3=3'b111;

	reg[2:0] state_reg, state_next;
	
	assign dirsw=sw; // przepisanie wejœcia na wyjœcie
	assign dirsw_neg=~sw; // przepisanie wejœcia na wyjœcie
	assign dbsw_neg=~dbsw; // zanegowane wyjœcie - przydatne przy pullup
	
	assign state=state_reg; // udostêpnienie stanu

	always @(posedge swclock)
	begin
		state_reg<=state_next;
	end
	
	// next-state logic
	always @*
	begin
		state_next=state_reg;
		dbsw=1'b1; // pullup
		
		case(state_reg)
			zero:
				begin
					dbsw=1'b0;
					if(sw)
						state_next=wait1_1;
				end
			wait1_1:
				begin
					dbsw=1'b0;
					if(~sw)
						state_next=zero;
					else
						if(swtick)
							state_next=wait1_2;
				end
			wait1_2:
				begin
					dbsw=1'b0;
					if(~sw)
						state_next=zero;
					else
						if(swtick)
							state_next=wait1_3;
				end
			wait1_3:
				begin
					dbsw=1'b0;
					if(~sw)
						state_next=zero;
					else
						if(swtick)
							state_next=one;
				end
			one:
				begin
					dbsw=1'b1;// nadmiarowe (wartoœæ domyœlna)
					if(~sw)
						state_next=wait0_1;
				end
			wait0_1:
				begin
					dbsw=1'b1;// nadmiarowe
					if(sw)
						state_next=one;
					else
						if(swtick)
							state_next=wait0_2;
				end				
			wait0_2:
				begin
					dbsw=1'b1;// nadmiarowe
					if(sw)
						state_next=one;
					else
						if(swtick)
							state_next=wait0_3;
				end				
			wait0_3:
				begin
					dbsw=1'b1; // nadmiarowe
					if(sw)
						state_next=one;
					else
						if(swtick)
							state_next=zero;
				end				
			default:
				state_next=one; // pullup
		endcase
	end


endmodule
