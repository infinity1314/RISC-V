module cpu_top(

    input wire clk,
    input wire reset,
    input wire [`InstAddrBus]if_pc,
    input wire [31:0]if_inst,
    output wire [`InstAddrBus]id_pc,
    output wire [31:0]id_inst
);

wire [`InstAddrBus]if_pc;
wire [`InstAddrBus]id_pc;
wire [`InstAddrBus]ex_pc;
wire [`InstAddrBus]me_pc;
wire [`InstAddrBus]wb_pc;

wire [`InstBus]if_inst;
wire [`InstBus]id_inst; 
wire [`InstBus]ex_inst;
wire [`InstBus]me_inst;
wire [`InstBus]wb_inst;

wire [`RegAddrBus]ex_w_addr;
wire [`RegAddrBus]me_w_addr;
wire [`RegAddrBus]wb_w_addr;

wire [`RegBus]ex_w_data;
wire [`RegBus]me_w_data;
wire [`RegBus]wb_w_data;
wire [`RegBus]ex_w_data;
wire [`RegBus]me_w_data;
wire [`RegBus]wb_w_data;

wire ex_w_enable;
wire me_w_enable;
wire wb_w_enable;
wire ex_w_enable;
wire me_w_enable;
wire wb_w_enable;
wire rom_busy_i;
wire rom_done_i;
wire stall_req_o;
wire rom_addr_o;
wire r_enable_o;

IF IF_inst(
    .rst(reset),
    .pc_i(if_pc),
    .rom_data_i(if_inst),
    .pc_o(id_pc),
    .inst_o(id_inst),
    .rom_addr_o(rom_addr_o),
    .r_enable_o(r_enable_o),
    .rom_busy_i(rom_busy_i),
    .rom_done_i(rom_done_i),
    .stall_req_o(stall_req_o)
);

IF_ID IF_ID_inst(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .if_inst(if_inst),
    .id_pc(id_pc),
    .id_inst(id_inst)
);

ID ID_inst(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .if_inst(if_inst),
    .id_pc(id_pc),
    .id_inst(id_inst)
);
ID_EX ID_EX_inst(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .if_inst(if_inst),
    .id_pc(id_pc),
    .id_inst(id_inst)
);
EX EX_inst(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .if_inst(if_inst),
    .id_pc(id_pc),
    .id_inst(id_inst)
);
EX_MEM EX_MEM_inst(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .if_inst(if_inst),
    .id_pc(id_pc),
    .id_inst(id_inst)
);
ME ME_inst(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .if_inst(if_inst),
    .id_pc(id_pc),
    .id_inst(id_inst)
);
ME_WB ME_WB_inst(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .if_inst(if_inst),
    .id_pc(id_pc),
    .id_inst(id_inst)
);
WB WB_inst(
    .clk(clk),
    .reset(reset),
    .if_pc(if_pc),
    .if_inst(if_inst),
    .id_pc(id_pc),
    .id_inst(id_inst)
);  
endmodule