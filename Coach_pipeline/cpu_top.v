`include "Defines.vh"
`include "ALUInstDef.vh"

// 五级流水线顶层：内建 IM（与 Coach 多周期一致），无 I-Cache / 分支预测。
// 分支与跳转在 EX 阶段判定；next_pc =  taken ? target : pc+4 。
module cpu_top(
    input wire clk,
    input wire reset
);

    // PC：与 Coach/PC.v 一致，复位到指令区起始
    localparam [31:0] PC_RESET = 32'h0000_2000;

    reg [`InstAddrBus] pc;
    wire [`InstAddrBus] next_pc;

    wire [`InstAddrBus] if_pc;
    wire [`InstBus]     if_inst;

    wire [`InstAddrBus] id_pc;
    wire [`InstBus]     id_inst;

    wire [`InstAddrBus] ex_pc;

    wire [`AluOpBus]     id_aluop_o;
    wire [`AluOutSelBus] id_alusel_o;
    wire [`RegBus]       id_r1_data_o;
    wire [`RegBus]       id_r2_data_o;
    wire                 id_w_enable_o;
    wire [`RegAddrBus]   id_w_addr_o;
    wire [`RegBus]       id_offset_o;

    wire [`AluOpBus]     ex_aluop_i;
    wire [`AluOutSelBus] ex_alusel_i;
    wire [`RegBus]       ex_r1_data_i;
    wire [`RegBus]       ex_r2_data_i;
    wire                 ex_w_enable_i;
    wire [`RegAddrBus]   ex_w_addr_i;
    wire [`RegBus]       ex_offset_i;

    wire [`RegBus]       ex_w_data_o;
    wire                 ex_b_flag_o;
    wire [`InstAddrBus]  ex_b_target_addr_o;
    wire                 ex_pre_ld_o;

    wire [`AluOpBus]     me_aluop_i;
    wire [`RegBus]       me_addr_i;
    wire [`RegBus]       me_r2_data_i;
    wire                 me_w_enable_i;
    wire [`RegAddrBus]   me_w_addr_i;

    wire [`RegBus]       mem_w_data_o;
    wire                 mem_w_enable_o;
    wire [`RegAddrBus]   mem_w_addr_o;

    wire [`RegBus]       wb_w_data_i;
    wire                 wb_w_enable_i;
    wire [`RegAddrBus]   wb_w_addr_i;

    wire                 rf_r1_enable_o;
    wire                 rf_r2_enable_o;
    wire [`RegAddrBus]   rf_r1_addr_o;
    wire [`RegAddrBus]   rf_r2_addr_o;
    wire [`RegBus]       rf_r1_data_i;
    wire [`RegBus]       rf_r2_data_i;

    wire [`RegBus]       rf_w_data_o;
    wire                 rf_w_enable_o;
    wire [`RegAddrBus]   rf_w_addr_o;

    wire [5:0]           stall_bus;
    wire                 id_flush;
    wire                 ex_flush;

    wire                 if_stall_req;
    wire [`InstBus]      im_inst;

    // 内建指令存储器（字地址 = PC[11:2]）
    IM u_im (
        .InsMemRW (1'b1),
        .addr     (pc[11:2]),
        .Ins      (im_inst)
    );

    IF u_if (
        .pc_i       (pc),
        .rom_data_i (im_inst),
        .if_pc_i    (if_pc),
        .inst_o     (if_inst),
        .stall_req_o(if_stall_req)
    );

    IF_ID u_if_id (
        .clk       (clk),
        .rst       (reset),
        .if_pc_o   (if_pc),
        .if_inst_o (if_inst),
        .id_pc_i   (id_pc),
        .id_inst_i (id_inst),
        .stall     (stall_bus),
        .ex_flush  (ex_flush),
        .id_flush  (id_flush)
    );

    regfile u_regfile (
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

    wire                 id_stall_req;
    wire [`InstAddrBus]  id_pc_o_for_branch;
    wire                 id_flush_flag_o;
    wire [`InstAddrBus]  id_j_target_addr_o;

    ID u_id (
        .rst             (reset),
        .id_pc_i         (id_pc),
        .id_inst_i       (id_inst),
        .r1_data_i       (rf_r1_data_i),
        .r2_data_i       (rf_r2_data_i),
        .r1_enable_o     (rf_r1_enable_o),
        .r2_enable_o     (rf_r2_enable_o),
        .r1_addr_o       (rf_r1_addr_o),
        .r2_addr_o       (rf_r2_addr_o),
        .aluop_o         (id_aluop_o),
        .alusel_o        (id_alusel_o),
        .r1_data_o       (id_r1_data_o),
        .r2_data_o       (id_r2_data_o),
        .w_enable_o      (id_w_enable_o),
        .w_addr_o        (id_w_addr_o),
        .ex_pre_ld       (ex_pre_ld_o),
        .ex_w_enable_i   (ex_w_enable_i),
        .ex_w_addr_i     (ex_w_addr_i),
        .ex_w_data_i     (ex_w_data_o),
        .me_w_enable_i   (me_w_enable_i),
        .me_w_addr_i     (me_w_addr_i),
        .me_w_data_i     (mem_w_data_o),
        .stall_req_o     (id_stall_req),
        .offset_o        (id_offset_o),
        .pc_o            (id_pc_o_for_branch),
        .flush_flag_o    (id_flush_flag_o),
        .j_target_addr_o (id_j_target_addr_o),
        .imm_o           (),
        .instvalid_o     ()
    );

    ID_EX u_id_ex (
        .clk          (clk),
        .reset        (reset),
        .id_pc        (id_pc),
        .id_aluop_o   (id_aluop_o),
        .id_alusel_o  (id_alusel_o),
        .ex_aluop_i   (ex_aluop_i),
        .ex_alusel_i  (ex_alusel_i),
        .id_r1_data_o (id_r1_data_o),
        .id_r2_data_o (id_r2_data_o),
        .ex_r1_data_i (ex_r1_data_i),
        .ex_r2_data_i (ex_r2_data_i),
        .id_w_enable_o(id_w_enable_o),
        .ex_w_enable_i(ex_w_enable_i),
        .id_w_addr_o  (id_w_addr_o),
        .ex_w_addr_i  (ex_w_addr_i),
        .ex_pc_i      (ex_pc),
        .id_offset_o  (id_offset_o),
        .ex_offset_i  (ex_offset_i),
        .ex_b_flag_i  (ex_b_flag_o),
        .stall        (stall_bus)
    );

    EX u_ex (
        .ex_pc_i              (ex_pc),
        .ex_aluop_i           (ex_aluop_i),
        .ex_alusel_i          (ex_alusel_i),
        .ex_r1_data_i         (ex_r1_data_i),
        .ex_r2_data_i         (ex_r2_data_i),
        .ex_offset_i          (ex_offset_i),
        .ex_w_enable_i        (ex_w_enable_i),
        .ex_w_addr_i          (ex_w_addr_i),
        .ex_w_data_o          (ex_w_data_o),
        .ex_w_b_flag_o        (ex_b_flag_o),
        .ex_w_b_target_addr_o (ex_b_target_addr_o),
        .ex_pre_ld_o          (ex_pre_ld_o),
        .me_pre_ld            (1'b0),
        .me_w_enable_i        (me_w_enable_i),
        .me_w_addr_i          (me_w_addr_i),
        .me_w_data_i          (mem_w_data_o)
    );

    EX_MEM u_ex_mem (
        .clk           (clk),
        .rst           (reset),
        .ex_aluop_i    (ex_aluop_i),
        .ex_w_data_o   (ex_w_data_o),
        .ex_r2_data_i  (ex_r2_data_i),
        .ex_w_enable_i (ex_w_enable_i),
        .ex_w_addr_i   (ex_w_addr_i),
        .me_aluop_i    (me_aluop_i),
        .me_addr_i     (me_addr_i),
        .me_r2_data_i  (me_r2_data_i),
        .me_w_enable_i (me_w_enable_i),
        .me_w_addr_i   (me_w_addr_i)
    );

    MEM u_mem (
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

    MEM_WB u_mem_wb (
        .clk             (clk),
        .rst             (reset),
        .mem_w_data_o    (mem_w_data_o),
        .mem_w_enable_o  (mem_w_enable_o),
        .mem_w_addr_o    (mem_w_addr_o),
        .wb_w_data_i     (wb_w_data_i),
        .wb_w_enable_i   (wb_w_enable_i),
        .wb_w_addr_i     (wb_w_addr_i)
    );

    WB u_wb (
        .wb_w_data_i   (wb_w_data_i),
        .wb_w_enable_i (wb_w_enable_i),
        .wb_w_addr_i   (wb_w_addr_i),
        .rf_w_data_o   (rf_w_data_o),
        .rf_w_enable_o (rf_w_enable_o),
        .rf_w_addr_o   (rf_w_addr_o)
    );

    // 无 ID 级“提前跳转”时，关闭 id_flush_flag，仅由 EX 的 ex_b_flag 冲刷流水线
    ctrl u_ctrl (
        .rst             (reset),
        .if_stall_req    (if_stall_req),
        .id_stall_req    (id_stall_req),
        .ex_b_flag_i     (ex_b_flag_o),
        .id_flush_flag_i (1'b0),
        .stall           (stall_bus),
        .id_flush        (id_flush),
        .ex_flush        (ex_flush)
    );

    assign next_pc = ex_b_flag_o ? ex_b_target_addr_o : (pc + 32'd4);

    always @(posedge clk) begin
        if (reset)
            pc <= PC_RESET;
        else if (!stall_bus[0])
            pc <= next_pc;
    end

endmodule
