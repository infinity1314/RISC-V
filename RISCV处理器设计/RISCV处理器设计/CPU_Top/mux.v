module mux(
            input [31:0]  source1,
            input [31:0]  source2,
			input [31:0]  source3,
            input [31:0]  source4,
            input  [1:0] select,
            output reg[31:0] result
        );
		
always@(*)	
		begin
		case(select)
				2'b00: result = source1;
				2'b01: result = source2;
				2'b10: result = source3;
				2'b11: result = source4;
				default: result = source1;
		
		endcase
		end
endmodule