//IF模块，负责从ROM中读取指令，并传到IF_ID模块
//输入：rst，复位信号
//输入：pc_i，当前PC地址
//输入：rom_data_i，ROM数据
//输出：if_pc_i，当前PC地址
//输出：inst_o，指令
//输出：rom_addr_o，ROM地址
//输出：r_enable_o，ROM读使能
//输出：stall_req_o， stall请求
//输入：rom_busy_i，ROM忙信号
//输入：rom_done_i，ROM完成信号
`ifndef _IF
`define _IF
`include "Defines.vh"
`include "IDInstDef.vh"

module IF (
    input wire  rst,
	input wire[`InstAddrBus]	pc_i,
	input wire[`InstBus]		rom_data_i,
	output reg[`InstAddrBus]	if_pc_i,
    output reg[`InstBus]    	inst_o,
	output wire[`InstAddrBus]	rom_addr_o,
	output reg 					r_enable_o,
	input wire					rom_busy_i,
	input wire					rom_done_i,
	output reg 					stall_req_o
);

assign rom_addr_o = pc_i;

always @ (*)
begin
	// 默认值，避免综合出锁存
	if_pc_i		=	`Zero;
	r_enable_o	=	1'b0;
	inst_o      =   `Zero;
	stall_req_o	=	1'b0;

    if (rst) 
    begin
		if_pc_i		=	`Zero;
		r_enable_o	=	1'b0;
		stall_req_o	=	1'b0;
        inst_o      =   `Zero;
    end
    else if (rom_done_i)
    begin
        if_pc_i		=	pc_i;
        inst_o      =	rom_data_i;        
        stall_req_o	=	1'b0;
    end
    else if (!rom_busy_i)
    begin
        r_enable_o	=	1'b1;
        stall_req_o	=	1'b1;
    end
	else if (rom_busy_i)
	begin
		r_enable_o	=	1'b0;
	    stall_req_o	=	1'b1;
	end
end

endmodule
`endif