`ifndef _DMEM
`define _DMEM
`include "Defines.vh"

// 简单数据 RAM：
// - DataMemNum 个 32bit 字
// - 同步写、同步读
// - 建议在 testbench 中用 $readmemh 初始化
module dmem(
    input  wire                 clk,
    input  wire                 rst,

    input  wire                 we_i,
    input  wire[3:0]            be_i,      // byte enable for SB/SH/SW
    input  wire[`DataAddrBus]   addr_i,
    input  wire[`DataBus]       wdata_i,
    output reg [`DataBus]       rdata_o
);

    reg[`DataBus] mem[0:`DataMemNum-1];

    wire[`DataMemNumLog2-1:0] word_index = addr_i[`DataMemNumLog2+1:2]; // 以字对齐

    always @(posedge clk) begin
        if (rst) begin
            // 留空；仿真时用 $readmemh 初始化 mem[]
            rdata_o <= `Zero;
        end else begin
            if (we_i) begin
                if (be_i[0]) mem[word_index][7:0]   <= wdata_i[7:0];
                if (be_i[1]) mem[word_index][15:8]  <= wdata_i[15:8];
                if (be_i[2]) mem[word_index][23:16] <= wdata_i[23:16];
                if (be_i[3]) mem[word_index][31:24] <= wdata_i[31:24];
            end
            rdata_o <= mem[word_index];
        end
    end

endmodule
`endif

