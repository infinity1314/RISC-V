`ifndef _WB
`define _WB
`include "Defines.vh"

// WB 阶段：当前仅作为直通，将 MEM_WB 打拍后的信号送入寄存器堆
module WB(
    // 来自 MEM_WB 阶段
    input  wire[`RegBus]        wb_w_data_i,
    input  wire                 wb_w_enable_i,
    input  wire[`RegAddrBus]    wb_w_addr_i,

    // 送往 regfile 的写回端口
    output wire[`RegBus]        rf_w_data_o,
    output wire                 rf_w_enable_o,
    output wire[`RegAddrBus]    rf_w_addr_o
);

    assign rf_w_data_o   = wb_w_data_i;
    assign rf_w_enable_o = wb_w_enable_i;
    assign rf_w_addr_o   = wb_w_addr_i;

endmodule
`endif
