// 流水线专用寄存器堆（双读一写），与 Coach 的 RF.v 并存。
`ifndef _PIPELINE_REGFILE
`define _PIPELINE_REGFILE
`include "Defines.vh"

module pipeline_regfile (
    input  wire                 clk,
    input  wire                 rst,

    input  wire                 r1_enable_i,
    input  wire [`RegAddrBus]   r1_addr_i,
    output reg  [`RegBus]       r1_data_o,

    input  wire                 r2_enable_i,
    input  wire [`RegAddrBus]   r2_addr_i,
    output reg  [`RegBus]       r2_data_o,

    input  wire                 w_enable_i,
    input  wire [`RegAddrBus]   w_addr_i,
    input  wire [`RegBus]       w_data_i
);

    reg [`RegBus] regs[0:31];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= `Zero;
        end else if (w_enable_i == `WriteEnable && w_addr_i != `NOPRegAddr) begin
            regs[w_addr_i] <= w_data_i;
        end
    end

    always @(*) begin
        if (r1_enable_i == `ReadEnable && r1_addr_i != `NOPRegAddr)
            r1_data_o = regs[r1_addr_i];
        else
            r1_data_o = `Zero;
    end

    always @(*) begin
        if (r2_enable_i == `ReadEnable && r2_addr_i != `NOPRegAddr)
            r2_data_o = regs[r2_addr_i];
        else
            r2_data_o = `Zero;
    end

endmodule
`endif
