`ifndef _EX
`define _EX
`include "Defines.vh"
`include "IDInstDef.vh"
`include "ALUInstDef.vh"

module EX(
    input wire [`InstAddrBus] ex_pc_i,
    input wire [`AluOpBus]    ex_aluop_i,
    input wire [`AluOutSelBus] ex_alusel_i,
    input wire [`RegBus]      ex_r1_data_i,
    input wire [`RegBus]      ex_r2_data_i,
    input wire [`RegBus]      ex_offset_i,   // 来自 ID_EX 的偏移量
    input wire                ex_w_enable_i,
    input wire [`RegAddrBus]  ex_w_addr_i,

    output reg [`RegBus]      ex_w_data_o,
    output reg                ex_w_b_flag_o,
    output reg [`InstAddrBus] ex_w_b_target_addr_o,
    output wire               ex_pre_ld_o,   // 当前 EX 是否为 load，用于 ID 的 load-use 冒险检测

    // 目前 EX 阶段不直接处理与 MEM 的前递，这里先预留接口
    input wire                me_pre_ld,
    input wire                me_w_enable_i,
    input wire [`RegAddrBus]  me_w_addr_i,
    input wire [`RegBus]      me_w_data_i
);

    wire [`RegBus] alu_result;
    wire           alu_zero;
    wire           alu_overflow;

    // 使用 EX 阶段的两个源操作数驱动 ALU
    ALU u_alu (
        .source1 (ex_r1_data_i),
        .source2 (ex_r2_data_i),
        .aluop   (ex_aluop_i),
        .result  (alu_result),
        .zero    (alu_zero),
        .overflow(alu_overflow)
    );

    // 当前 EX 指令是否为 load（用于 ID 阶段 load-use 冒险检测）
    assign ex_pre_ld_o = (ex_aluop_i == `EX_LB_OP  ||
                          ex_aluop_i == `EX_LH_OP  ||
                          ex_aluop_i == `EX_LW_OP  ||
                          ex_aluop_i == `EX_LBU_OP ||
                          ex_aluop_i == `EX_LHU_OP);

    always @(*) begin
        // 默认：不分支，写回 0
        ex_w_data_o          = `Zero;
        ex_w_b_flag_o        = 1'b0;
        ex_w_b_target_addr_o = `Zero;

        // 计算写回数据（根据 alusel 选择不同结果）
        case (ex_alusel_i)
            `EX_RES_LOGIC,
            `EX_RES_ARITH,
            `EX_RES_SHIFT,
            `EX_RES_LD_ST: begin
                // 这些类型目前都直接采用 ALU 结果：
                //  - 逻辑/算术/移位：结果就是运算值
                //  - Load/Store：结果是地址（后续在 MEM 阶段再用）
                ex_w_data_o = alu_result;
            end

            `EX_RES_J_B: begin
                // JAL/JALR 写回 PC+4
                ex_w_data_o = ex_pc_i + 32'd4;
            end

            default: begin
                ex_w_data_o = `Zero;
            end
        endcase

        // 分支/跳转标志与目标地址：
        // 这里简单按 aluop_i 判断，需要与 ID 阶段的编码保持一致。
        case (ex_aluop_i)
            `EX_JAL_OP,
            `EX_JALR_OP: begin
                // 对于 JAL/JALR，总是“跳转”，目标 = ex_pc + offset
                ex_w_b_flag_o        = 1'b1;
                ex_w_b_target_addr_o = ex_pc_i + ex_offset_i;
            end

            `EX_BEQ_OP: begin
                ex_w_b_flag_o        = (ex_r1_data_i == ex_r2_data_i);
                ex_w_b_target_addr_o = ex_pc_i + ex_offset_i;
            end

            `EX_BNE_OP: begin
                ex_w_b_flag_o        = (ex_r1_data_i != ex_r2_data_i);
                ex_w_b_target_addr_o = ex_pc_i + ex_offset_i;
            end

            `EX_BLT_OP: begin
                ex_w_b_flag_o        = ($signed(ex_r1_data_i) < $signed(ex_r2_data_i));
                ex_w_b_target_addr_o = ex_pc_i + ex_offset_i;
            end

            `EX_BGE_OP: begin
                ex_w_b_flag_o        = !($signed(ex_r1_data_i) < $signed(ex_r2_data_i));
                ex_w_b_target_addr_o = ex_pc_i + ex_offset_i;
            end

            `EX_BLTU_OP: begin
                ex_w_b_flag_o        = (ex_r1_data_i < ex_r2_data_i);
                ex_w_b_target_addr_o = ex_pc_i + ex_offset_i;
            end

            `EX_BGEU_OP: begin
                ex_w_b_flag_o        = !(ex_r1_data_i < ex_r2_data_i);
                ex_w_b_target_addr_o = ex_pc_i + ex_offset_i;
            end

            default: begin
                ex_w_b_flag_o        = 1'b0;
                ex_w_b_target_addr_o = `Zero;
            end
        endcase
    end

endmodule
`endif