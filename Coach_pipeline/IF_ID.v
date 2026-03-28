//IF_ID模块，负责将IF模块传来的指令和PC地址传到ID模块
//输入：clk，时钟信号
//输入：rst，复位信号
//输入：if_pc_o，IF模块传来的PC地址
//输入：if_inst_o，IF模块传来的指令
//输出：id_pc_i，ID模块要传入的PC地址
//输出：id_inst_i，ID模块要传入的指令
//输入：stall， stall请求
//输入：ex_flush，ex模块flush请求
//输入：id_flush，id模块flush请求


`ifndef _IF_ID
`define	_IF_ID
`include "Defines.vh"
`include "IDInstDef.vh"

module IF_ID(
	input wire	clk,
	input wire	rst,

	input wire[`InstAddrBus]	if_pc_o,
	input wire[`InstBus]		if_inst_o,

	output reg[`InstAddrBus]	id_pc_i,
	output reg[`InstBus]		id_inst_i,

	input wire[5:0]				stall,

	input wire					ex_flush,
	input wire					id_flush
);

reg					next_jump;
reg[`InstAddrBus]	next_pc;
reg[`InstBus]		next_inst;

initial
begin
	next_jump	<=	1'b0;
end

always @ (posedge clk)
begin
	if (rst)
	begin
		id_pc_i				<=  `Zero;
		id_inst_i 			<=  `Zero;
		next_jump			<=	1'b0;
	end
	else 
	begin
		if (ex_flush || id_flush)
		begin
			if (stall[1] && !stall[2])
			begin
				id_pc_i 		<=	`Zero;
				id_inst_i		<=	`Zero;
				next_jump		<=	1'b1;
			end
			else if (stall[1] && stall[2])
			begin
				next_jump 		<=	1'b1;
			end
			else
			begin
				id_pc_i 		<=	`Zero;
				id_inst_i		<=	`Zero;
				next_jump		<=	1'b0;
			end
		end
		else if(stall[1] && !stall[2])
		begin
			id_pc_i 			<=	`Zero;
			id_inst_i			<=	`Zero;
		end
		else if (!stall[1])
		begin
			if (next_jump)
			begin
				id_pc_i 		<=	`Zero;
				id_inst_i		<=	`Zero;
				next_jump		<=	1'b0;
			end
			else
			begin
				id_pc_i		    <=	if_pc_o;
				id_inst_i		<=	if_inst_o;
				next_jump	    <=	1'b0;
			end
		end
	end
end

endmodule

`endif