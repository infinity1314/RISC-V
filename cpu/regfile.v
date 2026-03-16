`ifndef _REGFILE
`define _REGFILE
`include "Defines.vh"

// 通用寄存器堆：32×32bit，两个读口，一个写口，x0 恒为 0
module regfile(
    input  wire                 clk,
    input  wire                 rst,

    // 读端口 1
    input  wire                 r1_enable_i,
    input  wire[`RegAddrBus]    r1_addr_i,
    output reg [`RegBus]        r1_data_o,

    // 读端口 2
    input  wire                 r2_enable_i,
    input  wire[`RegAddrBus]    r2_addr_i,
    output reg [`RegBus]        r2_data_o,

    // 写端口
    input  wire                 w_enable_i,
    input  wire[`RegAddrBus]    w_addr_i,
    input  wire[`RegBus]        w_data_i
);

    reg[`RegBus] regs[0:31];

    integer i;

    // 同步写、异步读
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                regs[i] <= `Zero;
            end
        end else if (w_enable_i == `WriteEnable && w_addr_i != `NOPRegAddr) begin
            regs[w_addr_i] <= w_data_i;
        end
    end

    // 读端口 1：x0 恒为 0
    always @(*) begin
        if (r1_enable_i == `ReadEnable && r1_addr_i != `NOPRegAddr) begin
            r1_data_o = regs[r1_addr_i];
        end else begin
            r1_data_o = `Zero;
        end
    end

    // 读端口 2：x0 恒为 0
    always @(*) begin
        if (r2_enable_i == `ReadEnable && r2_addr_i != `NOPRegAddr) begin
            r2_data_o = regs[r2_addr_i];
        end else begin
            r2_data_o = `Zero;
        end
    end

endmodule
`endif