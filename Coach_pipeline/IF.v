// IF：组合逻辑取指（配合内建 IM，无 ROM 握手延迟）
`ifndef _IF
`define _IF
`include "Defines.vh"

module IF (
    input  wire [`InstAddrBus] pc_i,
    input  wire [`InstBus]     rom_data_i,
    output wire [`InstAddrBus] if_pc_i,
    output wire [`InstBus]     inst_o,
    output wire                stall_req_o
);

    assign if_pc_i     = pc_i;
    assign inst_o      = rom_data_i;
    assign stall_req_o = 1'b0;

endmodule
`endif
