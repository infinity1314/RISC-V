`include "Defines.vh"
`include "ALUInstDef.vh"

module ALU(
    input  wire[`RegBus]    source1,
    input  wire[`RegBus]    source2,
    input  wire[`AluOpBus]  aluop,
    output reg [`RegBus]    result,
    output wire             zero,
    output wire             overflow
);

// 提前算好加减，便于判断溢出
wire [31:0] sum    = source1 + source2;
wire [31:0] diff   = source1 - source2;

// 有符号加法/减法溢出检测（简单实现）
wire        sum_of  = (source1[31] == source2[31]) && (sum[31]  != source1[31]);
wire        diff_of = (source1[31] != source2[31]) && (diff[31] != source1[31]);

always @(*) begin
    case (aluop)
        // 逻辑运算
        `EX_OR_OP:   result = source1 |  source2;
        `EX_AND_OP:  result = source1 &  source2;
        `EX_XOR_OP:  result = source1 ^  source2;

        // 加法类（普通 add、auipc、load/store 的地址计算都视作加法）
        `EX_ADD_OP,
        `EX_AUIPC_OP,
        `EX_LB_OP, `EX_LH_OP, `EX_LW_OP,
        `EX_LBU_OP, `EX_LHU_OP,
        `EX_SB_OP, `EX_SH_OP, `EX_SW_OP:
                     result = sum;

        // 减法
        `EX_SUB_OP:  result = diff;

        // 比较
        `EX_SLT_OP:  result = ($signed(source1) < $signed(source2)) ? 32'b1 : 32'b0;
        `EX_SLTU_OP: result = (source1 < source2)                     ? 32'b1 : 32'b0;

        // 移位
        `EX_SLL_OP:  result = source1 <<  source2[4:0];
        `EX_SRL_OP:  result = source1 >>  source2[4:0];
        `EX_SRA_OP:  result = $signed(source1) >>> source2[4:0];

        // 分支/跳转：通常不直接用 ALU 的 result，当作 NOP 处理即可
        `EX_JAL_OP,
        `EX_JALR_OP,
        `EX_BEQ_OP,  `EX_BNE_OP,
        `EX_BLT_OP,  `EX_BGE_OP,
        `EX_BLTU_OP, `EX_BGEU_OP:
                     result = `Zero;

        default:     result = `Zero;
    endcase
end

// zero 标志：结果是否为 0（分支、比较等可以用）
assign zero = (result == 32'b0);

// overflow 标志：只在加减类运算有效
assign overflow =
       (aluop == `EX_ADD_OP || aluop == `EX_AUIPC_OP ||
        aluop == `EX_LB_OP  || aluop == `EX_LH_OP    || aluop == `EX_LW_OP ||
        aluop == `EX_LBU_OP || aluop == `EX_LHU_OP   ||
        aluop == `EX_SB_OP  || aluop == `EX_SH_OP    || aluop == `EX_SW_OP)
           ? sum_of  :
       (aluop == `EX_SUB_OP ? diff_of : 1'b0);

endmodule