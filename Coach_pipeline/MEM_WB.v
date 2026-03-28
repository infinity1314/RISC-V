`ifndef _MEM_WB
`define _MEM_WB
`include "Defines.vh"

// MEM_WB：将 MEM 阶段的写回信息打拍到 WB 阶段
module MEM_WB(
    input  wire                 clk,
    input  wire                 rst,

    // 来自 MEM 阶段
    input  wire[`RegBus]        mem_w_data_o,
    input  wire                 mem_w_enable_o,
    input  wire[`RegAddrBus]    mem_w_addr_o,

    // 送往 WB 阶段
    output reg [`RegBus]        wb_w_data_i,
    output reg                  wb_w_enable_i,
    output reg [`RegAddrBus]    wb_w_addr_i
);

    always @(posedge clk) begin
        if (rst) begin
            wb_w_data_i   <= `Zero;
            wb_w_enable_i <= `WriteDisable;
            wb_w_addr_i   <= `NOPRegAddr;
        end else begin
            wb_w_data_i   <= mem_w_data_o;
            wb_w_enable_i <= mem_w_enable_o;
            wb_w_addr_i   <= mem_w_addr_o;
        end
    end

endmodule
`endif
