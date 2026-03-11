module add32 (
            input [31:0]  source1,
            input [31:0]  source2,
            output  reg [31:0] result
        );   
		always  @(source1 or source2)
		result=source1+source2;
endmodule