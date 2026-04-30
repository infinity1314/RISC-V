`timescale 1ns / 1ps

module riscv(
    input clk, rst,
    output [31:0] out_ins, DR_out
);

wire RFWrite, DMCtrl, PCWrite, IRWrite, InsMemRW, ExtSel, zero, ALUSrcA;
wire [1:0] ALUSrcB;
wire [1:0] NPCOp, WDsel, RegSel;
wire [3:0] ALUOp;
wire [6:0] opcode;
wire [2:0] Funct3;
wire [6:0] Funct7;

wire [31:0] PC, NPC, PC4A;
wire [31:0] in_ins, RD;

wire [4:0] rs1, rs2, rd;
wire [11:0] Imm12;
wire [31:0] Imm32;
wire [20:1] Offset20;
wire [11:0] Offset;

wire [4:0] WR;
wire [31:0] WD;

wire [31:0] RD1, RD1_r, RD2, RD2_r;
wire [31:0] A, B, ALU_result, ALU_result_r;

// ================= 指令字段解析 =================
assign opcode = out_ins[6:0];
assign Funct3 = out_ins[14:12];
assign Funct7 = out_ins[31:25];
assign rs1    = out_ins[19:15];
assign rs2    = out_ins[24:20];
assign rd     = out_ins[11:7];
assign Imm12  = out_ins[31:20];

assign Offset20 = {out_ins[31], out_ins[19:12], out_ins[20], out_ins[30:21]};

assign Offset =
    (opcode == `INSTR_BTYPE_OP) ?
    {out_ins[31], out_ins[7], out_ins[30:25], out_ins[11:8]} :
    (opcode == `INSTR_SW_OP) ?
    {out_ins[31:25], out_ins[11:7]} :
    Imm12;

// ================= 控制单元 =================
ControlUnit U_ControlUnit(
    .clk(clk), .rst(rst), .zero(zero),
    .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
    .RFWrite(RFWrite), .DMCtrl(DMCtrl),
    .PCWrite(PCWrite), .IRWrite(IRWrite),
    .InsMemRW(InsMemRW),
    .ExtSel(ExtSel), .ALUOp(ALUOp),
    .NPCOp(NPCOp), .ALUSrcA(ALUSrcA),
    .WDsel(WDsel), .ALUSrcB(ALUSrcB),
    .RegSel(RegSel)
);

// ================= PC =================
PC U_PC(
    .clk(clk), .rst(rst),
    .PCWrite(PCWrite),
    .NPC(NPC),
    .PC(PC)
);

// ================= NPC =================
NPC U_NPC(
    .PC(PC), .NPCOp(NPCOp),
    .Offset12(Offset),
    .Offset20(Offset20),
    .rs({2'b0, RD1[31:2]}),
    .PC4A(PC4A),
    .NPC(NPC)
);

// ================= 指令存储 =================
IM U_IM(
    .clk(clk),
    .addr(NPC[11:2]),
    .Ins(in_ins),
    .InsMemRW(InsMemRW)
);

// ================= IR =================
IR U_IR(
    .clk(clk),
    .IRWrite(IRWrite),
    .in_ins(in_ins),
    .out_ins(out_ins)
);

// ================= 寄存器堆 =================
RF U_RF(
    .RR1(rs1), .RR2(rs2),
    .WR(WR), .WD(WD),
    .clk(clk),
    .RFWrite(RFWrite),
    .RD1(RD1), .RD2(RD2)
);

// ================= 写回寄存器选择 =================
MUX_3to1 U_MUX_3to1(
    .X(rd),
    .Y(5'd0),
    .Z(5'd31),
    .control(RegSel),
    .out(WR)
);

// ================= 写回数据选择 =================
MUX_3to1_LMD U_MUX_3to1_LMD(
    .X(ALU_result_r),
    .Y(DR_out),
    .Z(PC4A[29:0]),
    .control(WDsel),
    .out(WD)
);

// ================= A寄存器 =================
Flopr U_A(
    .clk(clk), .rst(rst),
    .in_data(RD1),
    .out_data(RD1_r)
);

// ================= B寄存器 =================
Flopr U_B(
    .clk(clk), .rst(rst),
    .in_data(RD2),
    .out_data(RD2_r)
);

// ================= 立即数扩展 =================
EXT U_EXT(
    .imm_in(Imm12),
    .ExtSel(ExtSel),
    .imm_out(Imm32)
);

// ================= ALU输入A =================
MUX_2to1_A U_MUX_2to1_A(
    .X(RD1_r),
    .Y(5'b0),
    .control(ALUSrcA),
    .out(A)
);

// ================= ALU输入B =================
MUX_3to1_B U_MUX_3to1_B(
    .X(RD2_r),
    .Y(Imm32),
    .Z(Offset),
    .control(ALUSrcB),
    .out(B)
);

// ================= ALU =================
ALU U_ALU(
    .A(A), .B(B),
    .ALUOp(ALUOp),
    .ALU_result(ALU_result),
    .zero(zero)
);

// ================= ALU输出寄存器 =================
Flopr U_ALUOut(
    .clk(clk), .rst(rst),
    .in_data(ALU_result),
    .out_data(ALU_result_r)
);

// ================= 数据存储 =================
DM U_DM(
    .addr(ALU_result_r[11:2]),
    .WD(RD2_r),
    .DMCtrl(DMCtrl),
    .clk(clk),
    .RD(RD)
);

// ================= 输出 =================
assign DR_out = RD;

endmodule