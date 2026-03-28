`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ALU(
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALUOp,
    output wire        zero,
    output reg  [31:0] ALU_result
);

    // 移位量只取低 5 位（RV32I）
    wire [4:0] shamt = B[4:0];

    always @(*) begin
        case (ALUOp)
            `ALUOp_ADD:  ALU_result = A + B;
            `ALUOp_SUB:  ALU_result = A - B;
            `ALUOp_AND:  ALU_result = A & B;
            `ALUOp_OR:   ALU_result = A | B;
            `ALUOp_XOR:  ALU_result = A ^ B;
            `ALUOp_SLL:  ALU_result = A << shamt;
            `ALUOp_SRL:  ALU_result = A >> shamt;
            `ALUOp_SRA:  ALU_result = $signed(A) >>> shamt;
            // 分支 beq/bne：比较是否相等 → 做减法，zero 表示 A==B
            `ALUOp_BR:   ALU_result = A - B;
            default:     ALU_result = 32'b0;
        endcase
    end

    assign zero = (ALU_result == 32'b0);

endmodule
