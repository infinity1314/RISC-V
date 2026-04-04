`ifndef _MEM
`define _MEM
`include "Defines.vh"
`include "ALUInstDef.vh"

// MEM 阶段：实现对数据 RAM 的 LOAD/STORE 访问。
module MEM(
    input  wire                 clk,
    input  wire                 rst,

    // 来自 EX_MEM
    input  wire[`AluOpBus]      me_aluop_i,
    input  wire[`RegBus]        me_addr_i,
    input  wire[`RegBus]        me_r2_data_i,
    input  wire                 me_w_enable_i,
    input  wire[`RegAddrBus]    me_w_addr_i,

    // 写回到 MEM_WB
    output reg [`RegBus]        mem_w_data_o,
    output reg                  mem_w_enable_o,
    output reg [`RegAddrBus]    mem_w_addr_o
);

    // 与独立数据 RAM 的连接
    wire                 d_we;
    wire[3:0]            d_be;
    wire[`DataAddrBus]   d_addr;
    wire[`DataBus]       d_wdata;
    wire[`DataBus]       d_rdata;

    assign d_addr  = me_addr_i[`DataAddrBus];
    assign d_wdata = me_r2_data_i;

    // 生成 byte enable：支持 SB / SH / SW
    wire[1:0] byte_off = d_addr[1:0];
    assign d_we = (me_aluop_i == `EX_SB_OP ||
                   me_aluop_i == `EX_SH_OP ||
                   me_aluop_i == `EX_SW_OP);

    assign d_be =
        (me_aluop_i == `EX_SW_OP) ? 4'b1111 :
        (me_aluop_i == `EX_SH_OP) ? ( (byte_off[1] == 1'b0) ? 4'b0011 : 4'b1100 ) :
        (me_aluop_i == `EX_SB_OP) ? ( 4'b0001 << byte_off ) :
                                    4'b0000;

    dmem u_dmem(
        .clk    (clk),
        .rst    (rst),
        .we_i   (d_we),
        .be_i   (d_be),
        .addr_i (d_addr),
        .wdata_i(d_wdata),
        .rdata_o(d_rdata)
    );

    always @(*) begin
        // 默认：直接将 EX 结果（me_addr_i）作为写回数据（如算术结果）
        mem_w_data_o   = me_addr_i;
        mem_w_enable_o = me_w_enable_i;
        mem_w_addr_o   = me_w_addr_i;

        case (me_aluop_i)
            // LOAD 类，根据偏移做字节/半字选取与扩展
            `EX_LB_OP: begin
                case (byte_off)
                    2'b00: mem_w_data_o = {{24{d_rdata[7]}},  d_rdata[7:0]};
                    2'b01: mem_w_data_o = {{24{d_rdata[15]}}, d_rdata[15:8]};
                    2'b10: mem_w_data_o = {{24{d_rdata[23]}}, d_rdata[23:16]};
                    2'b11: mem_w_data_o = {{24{d_rdata[31]}}, d_rdata[31:24]};
                endcase
                mem_w_enable_o = me_w_enable_i;
                mem_w_addr_o   = me_w_addr_i;
            end
            `EX_LBU_OP: begin
                case (byte_off)
                    2'b00: mem_w_data_o = {24'h0, d_rdata[7:0]};
                    2'b01: mem_w_data_o = {24'h0, d_rdata[15:8]};
                    2'b10: mem_w_data_o = {24'h0, d_rdata[23:16]};
                    2'b11: mem_w_data_o = {24'h0, d_rdata[31:24]};
                endcase
                mem_w_enable_o = me_w_enable_i;
                mem_w_addr_o   = me_w_addr_i;
            end
            `EX_LH_OP: begin
                case (byte_off[1]) // 以半字对齐：00 或 10
                    1'b0: mem_w_data_o = {{16{d_rdata[15]}}, d_rdata[15:0]};
                    1'b1: mem_w_data_o = {{16{d_rdata[31]}}, d_rdata[31:16]};
                endcase
                mem_w_enable_o = me_w_enable_i;
                mem_w_addr_o   = me_w_addr_i;
            end
            `EX_LHU_OP: begin
                case (byte_off[1])
                    1'b0: mem_w_data_o = {16'h0, d_rdata[15:0]};
                    1'b1: mem_w_data_o = {16'h0, d_rdata[31:16]};
                endcase
                mem_w_enable_o = me_w_enable_i;
                mem_w_addr_o   = me_w_addr_i;
            end
            `EX_LW_OP: begin
                mem_w_data_o   = d_rdata;
                mem_w_enable_o = me_w_enable_i; // 写回寄存器
                mem_w_addr_o   = me_w_addr_i;
            end
            `EX_SB_OP,
            `EX_SH_OP,
            `EX_SW_OP: begin
                // STORE 指令：不向寄存器写回
                mem_w_data_o   = `Zero;
                mem_w_enable_o = `WriteDisable;
                mem_w_addr_o   = `NOPRegAddr;
            end

            default: begin
                // 其他指令：保持默认透传
            end
        endcase
    end

endmodule
`endif
