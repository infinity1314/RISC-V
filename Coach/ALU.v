`include "ctrl_signal_def.v"
`include "instruction_def.v"
module ALU(A,B,ALUOp,zero,ALU_result

);
    input [31:0] A,B;
    input [3:0] ALUOp;
    output zero;
    output reg signed [31:0] ALU_result;



    
endmodule