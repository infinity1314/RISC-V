`include "Defines.vh"
`include "ALUInstDef.vh"

// cpu 顶层：简化版五级流水连接
// 外部提供：clk、reset、指令 ROM 接口（地址/数据/握手）
module cpu_top(
    input  wire                 clk,
    input  wire                 reset,

    // 指令存储器接口（简化版）
    output wire[`InstAddrBus]   rom_addr_o,
    output wire                 rom_en_o,
    input  wire[`InstBus]       rom_data_i,
    input  wire                 rom_busy_i,
    input  wire                 rom_done_i
);

    // PC 寄存器与下一条 PC
    reg[`InstAddrBus]  pc;
    wire[`InstAddrBus] next_pc;

    // 流水线之间的 PC / 指令
    wire[`InstAddrBus] if_pc;
    wire[`InstBus]     if_inst;

    wire[`InstAddrBus] id_pc;
    wire[`InstBus]     id_inst;

    wire[`InstAddrBus] ex_pc;

    // ID -> ID_EX -> EX 的控制与数据信号
    wire[`AluOpBus]      id_aluop_o;
    wire[`AluOutSelBus]  id_alusel_o;
    wire[`RegBus]        id_r1_data_o;
    wire[`RegBus]        id_r2_data_o;
    wire                  id_w_enable_o;
    wire[`RegAddrBus]    id_w_addr_o;
    wire[`RegBus]        id_offset_o;

    wire[`AluOpBus]      ex_aluop_i;
    wire[`AluOutSelBus]  ex_alusel_i;
    wire[`RegBus]        ex_r1_data_i;
    wire[`RegBus]        ex_r2_data_i;
    wire                  ex_w_enable_i;
    wire[`RegAddrBus]    ex_w_addr_i;
    wire[`RegBus]        ex_offset_i; // 目前 EX 未使用

    // EX -> EX_MEM -> MEM -> MEM_WB -> WB 的写回路径
    wire[`RegBus]        ex_w_data_o;
    wire                 ex_b_flag_o;
    wire[`InstAddrBus]   ex_b_target_addr_o;
    wire                 ex_pre_ld_o;

    wire[`AluOpBus]      me_aluop_i;
    wire[`RegBus]        me_addr_i;
    wire[`RegBus]        me_r2_data_i;
    wire                 me_w_enable_i;
    wire[`RegAddrBus]    me_w_addr_i;

    wire[`RegBus]        mem_w_data_o;
    wire                 mem_w_enable_o;
    wire[`RegAddrBus]    mem_w_addr_o;

    wire[`RegBus]        wb_w_data_i;
    wire                 wb_w_enable_i;
    wire[`RegAddrBus]    wb_w_addr_i;

    // regfile 读写端口
    wire                 rf_r1_enable_o;
    wire                 rf_r2_enable_o;
    wire[`RegAddrBus]    rf_r1_addr_o;
    wire[`RegAddrBus]    rf_r2_addr_o;
    wire[`RegBus]        rf_r1_data_i;
    wire[`RegBus]        rf_r2_data_i;

    wire[`RegBus]        rf_w_data_o;
    wire                 rf_w_enable_o;
    wire[`RegAddrBus]    rf_w_addr_o;

    // 暂停/冲刷流水线相关信号
    wire[5:0]            stall_bus;
    wire                 id_flush;
    wire                 ex_flush;

    //================ IF 阶段 ================
    wire if_stall_req;

    // 分支预测信号
    wire                 bp_taken;
    wire[`InstAddrBus]   bp_target;
    // 用于 EX 阶段比较预测是否正确（打拍保存预测结果）
    reg                  id_pred_taken;
    reg[`InstAddrBus]    id_pred_target;

    // IF 与 ICache 之间的连接
    wire[`InstAddrBus] ic_if_addr;
    wire               ic_if_req;
    wire[`InstBus]     ic_if_inst;
    wire               ic_if_busy;
    wire               ic_if_done;

    // ICache 与外部 ROM 之间的连接
    wire[`InstAddrBus] ic_mem_addr;
    wire               ic_mem_en;

    IF u_if(
        .rst        (reset),
        .pc_i       (pc),
        .rom_data_i (ic_if_inst),
        .if_pc_i    (if_pc),
        .inst_o     (if_inst),
        .rom_addr_o (ic_if_addr),
        .r_enable_o (ic_if_req),
        .rom_busy_i (ic_if_busy),
        .rom_done_i (ic_if_done),
        .stall_req_o(if_stall_req)
    );

    //================ I-Cache ================
    icache u_icache(
        .clk        (clk),
        .rst        (reset),
        // 来自 IF 的取指
        .if_pc_i    (ic_if_addr),
        .if_req_i   (ic_if_req),
        .if_inst_o  (ic_if_inst),
        .if_busy_o  (ic_if_busy),
        .if_done_o  (ic_if_done),
        // 底层真实 ROM 接口（暴露给顶层端口）
        .mem_addr_o (rom_addr_o),
        .mem_en_o   (rom_en_o),
        .mem_data_i (rom_data_i),
        .mem_busy_i (rom_busy_i),
        .mem_done_i (rom_done_i)
    );

    //================ 分支预测器 ================
    branch_predictor u_bp(
        .clk            (clk),
        .rst            (reset),
        .pc_i           (pc),
        .pred_taken_o   (bp_taken),
        .pred_target_o  (bp_target),
        .update_valid_i (ex_b_flag_o),
        .update_pc_i    (ex_pc),
        .update_taken_i (ex_b_flag_o),
        .update_target_i(ex_b_target_addr_o)
    );

    //================ IF/ID 寄存器 ================
    IF_ID u_if_id(
        .clk        (clk),
        .rst        (reset),
        .if_pc_o    (if_pc),
        .if_inst_o  (if_inst),
        .id_pc_i    (id_pc),
        .id_inst_i  (id_inst),
        .stall      (stall_bus),
        .ex_flush   (ex_flush),
        .id_flush   (id_flush)
    );

    //================ 寄存器堆 ================
    regfile u_regfile(
        .clk         (clk),
        .rst         (reset),
        .r1_enable_i (rf_r1_enable_o),
        .r1_addr_i   (rf_r1_addr_o),
        .r1_data_o   (rf_r1_data_i),
        .r2_enable_i (rf_r2_enable_o),
        .r2_addr_i   (rf_r2_addr_o),
        .r2_data_o   (rf_r2_data_i),
        .w_enable_i  (rf_w_enable_o),
        .w_addr_i    (rf_w_addr_o),
        .w_data_i    (rf_w_data_o)
    );

    //================ ID 阶段 ================
    wire                 id_stall_req;
    wire[`InstAddrBus]   id_pc_o_for_branch;
    wire                 id_flush_flag_o;
    wire[`InstAddrBus]   id_j_target_addr_o;

    ID u_id(
        .rst            (reset),
        .id_pc_i        (id_pc),
        .id_inst_i      (id_inst),
        .r1_data_i      (rf_r1_data_i),
        .r2_data_i      (rf_r2_data_i),
        .r1_enable_o    (rf_r1_enable_o),
        .r2_enable_o    (rf_r2_enable_o),
        .r1_addr_o      (rf_r1_addr_o),
        .r2_addr_o      (rf_r2_addr_o),
        .aluop_o        (id_aluop_o),
        .alusel_o       (id_alusel_o),
        .r1_data_o      (id_r1_data_o),
        .r2_data_o      (id_r2_data_o),
        .w_enable_o     (id_w_enable_o),
        .w_addr_o       (id_w_addr_o),
        // 来自 EX 的 load-use 冒险检测信号
        .ex_pre_ld      (ex_pre_ld_o),
        .ex_w_enable_i  (ex_w_enable_i),
        .ex_w_addr_i    (ex_w_addr_i),
        .ex_w_data_i    (ex_w_data_o),
        .me_w_enable_i  (me_w_enable_i),
        .me_w_addr_i    (me_w_addr_i),
        .me_w_data_i    (mem_w_data_o),
        .stall_req_o    (id_stall_req),
        .offset_o       (id_offset_o),
        .pc_o           (id_pc_o_for_branch),
        .flush_flag_o   (id_flush_flag_o),
        .j_target_addr_o(id_j_target_addr_o),
        .imm_o          (/* 未使用 */),
        .instvalid_o    (/* 未使用 */)
    );

    //================ ID/EX 寄存器 ================
    ID_EX u_id_ex(
        .clk         (clk),
        .reset       (reset),
        .id_pc       (id_pc),
        .id_aluop_o  (id_aluop_o),
        .id_alusel_o (id_alusel_o),
        .ex_aluop_i  (ex_aluop_i),
        .ex_alusel_i (ex_alusel_i),
        .id_r1_data_o(id_r1_data_o),
        .id_r2_data_o(id_r2_data_o),
        .ex_r1_data_i(ex_r1_data_i),
        .ex_r2_data_i(ex_r2_data_i),
        .id_w_enable_o(id_w_enable_o),
        .ex_w_enable_i(ex_w_enable_i),
        .id_w_addr_o (id_w_addr_o),
        .ex_w_addr_i (ex_w_addr_i),
        .ex_pc_i     (ex_pc),
        .id_offset_o (id_offset_o),
        .ex_offset_i (ex_offset_i),
        .ex_b_flag_i (ex_b_flag_o),
        .stall       (stall_bus)
    );

    //================ EX 阶段 ================
    EX u_ex(
        .ex_pc_i            (ex_pc),
        .ex_aluop_i         (ex_aluop_i),
        .ex_alusel_i        (ex_alusel_i),
        .ex_r1_data_i       (ex_r1_data_i),
        .ex_r2_data_i       (ex_r2_data_i),
        .ex_offset_i        (ex_offset_i),
        .ex_w_enable_i      (ex_w_enable_i),
        .ex_w_addr_i        (ex_w_addr_i),
        .ex_w_data_o        (ex_w_data_o),
        .ex_w_b_flag_o      (ex_b_flag_o),
        .ex_w_b_target_addr_o(ex_b_target_addr_o),
        .ex_pre_ld_o        (ex_pre_ld_o),
        .me_pre_ld          (1'b0),
        .me_w_enable_i      (me_w_enable_i),
        .me_w_addr_i        (me_w_addr_i),
        .me_w_data_i        (mem_w_data_o)
    );

    //================ EX/MEM 寄存器 ================
    EX_MEM u_ex_mem(
        .clk          (clk),
        .rst          (reset),
        .ex_aluop_i   (ex_aluop_i),
        .ex_w_data_o  (ex_w_data_o),
        .ex_r2_data_i (ex_r2_data_i),
        .ex_w_enable_i(ex_w_enable_i),
        .ex_w_addr_i  (ex_w_addr_i),
        .me_aluop_i   (me_aluop_i),
        .me_addr_i    (me_addr_i),
        .me_r2_data_i (me_r2_data_i),
        .me_w_enable_i(me_w_enable_i),
        .me_w_addr_i  (me_w_addr_i)
    );

    //================ MEM 阶段 ================
    MEM u_mem(
        .clk            (clk),
        .rst            (reset),
        .me_aluop_i     (me_aluop_i),
        .me_addr_i      (me_addr_i),
        .me_r2_data_i   (me_r2_data_i),
        .me_w_enable_i  (me_w_enable_i),
        .me_w_addr_i    (me_w_addr_i),
        .mem_w_data_o   (mem_w_data_o),
        .mem_w_enable_o (mem_w_enable_o),
        .mem_w_addr_o   (mem_w_addr_o)
    );

    //================ MEM/WB 寄存器 ================
    MEM_WB u_mem_wb(
        .clk            (clk),
        .rst            (reset),
        .mem_w_data_o   (mem_w_data_o),
        .mem_w_enable_o (mem_w_enable_o),
        .mem_w_addr_o   (mem_w_addr_o),
        .wb_w_data_i    (wb_w_data_i),
        .wb_w_enable_i  (wb_w_enable_i),
        .wb_w_addr_i    (wb_w_addr_i)
    );

    //================ WB 阶段 ================
    WB u_wb(
        .wb_w_data_i   (wb_w_data_i),
        .wb_w_enable_i (wb_w_enable_i),
        .wb_w_addr_i   (wb_w_addr_i),
        .rf_w_data_o   (rf_w_data_o),
        .rf_w_enable_o (rf_w_enable_o),
        .rf_w_addr_o   (rf_w_addr_o)
    );

    //================ 流水线控制（暂停 / 冲刷） ================
    ctrl u_ctrl(
        .rst             (reset),
        .if_stall_req    (if_stall_req),
        .id_stall_req    (id_stall_req),
        .ex_b_flag_i     (ex_b_flag_o),
        .id_flush_flag_i (id_flush_flag_o),
        .stall           (stall_bus),
        .id_flush        (id_flush),
        .ex_flush        (ex_flush)
    );

    //================ PC 寄存器与 next_pc 逻辑 ================
    // 打拍保存 ID 阶段看到的预测结果，供 EX 比较
    always @(posedge clk) begin
        if (reset) begin
            id_pred_taken  <= 1'b0;
            id_pred_target <= `Zero;
        end else if (!stall_bus[1]) begin
            id_pred_taken  <= bp_taken;
            id_pred_target <= bp_target;
        end
    end

    // 简单的误预测检测：如果 EX 判定需要跳转，但预测没跳；或者预测跳了，但 EX 不跳；
    // 或者预测目标地址与实际不一致，都认为 mispredict，需要 flush + 修正 PC。
    wire ex_mispredict = (ex_b_flag_o != id_pred_taken) ||
                         (ex_b_flag_o && id_pred_taken && (ex_b_target_addr_o != id_pred_target));

    // next_pc 选择：EX 纠错 > 预测 > 顺序
    assign next_pc = ex_mispredict ? ex_b_target_addr_o :
                     bp_taken      ? bp_target           :
                                     (pc + 32'd4);

    always @(posedge clk) begin
        if (reset) begin
            pc <= `Zero;
        end else if (!stall_bus[0]) begin
            pc <= next_pc;
        end
        // 若 stall_bus[0] 为 1，则保持 pc 不变
    end

endmodule