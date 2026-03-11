module CPU_Top(
            input  clk_50M,
				input i_rst_n,
				
				output [7:0] Testled,
				
////////////外设接口//////////////////
			input   wire  	[7:0]    Key_press,
			output  wire	[7:0]   led,
			output	wire	[6:0] 	hex_0,
			output	wire	[6:0] 	hex_1,
			output	wire	[6:0] 	hex_2,
			output	wire	[6:0] 	hex_3,
			output	wire	[3:0]		hex_dp,
			
			input  i_rx_pin,
			output o_tx_pin
			
        );
parameter UART_BSP_RATE = 115200;//波特率
parameter CLK_PERIORD = 20;

wire pll_clk1;
wire pll_clk2;
wire pll_clk3;

wire i_clk = clk_50M;
PLL pll(
	.inclk0(clk_50M),
	.c0(pll_clk1),
	.c1(pll_clk2),
	.c2(pll_clk3));

wire[31:0] Address_Ins;
wire[31:0] Instruction;
wire[31:0] Data_Mem_Address;		//数据读写地址
wire[31:0] Data_Mem_WriteData;		//数据写入寄存器
wire[31:0] Data_Mem_Read;     		//数据读取寄存器
wire[31:0] Mem_Data_OR_PCI_Data_To_Cpu;
wire[0:0]  MemWrite;
wire[0:0]  MemRead;
wire[31:0] DataMenoryOut;
wire[0:0]  PCI_MEM_Ctrl;		//片选信号
wire[0:0]  Hit;
//对被测试的设计进行例化
cpuLSX cpu(
	.clk(i_clk),
	.reset_n(i_rst_n),
	.Address_Ins(Address_Ins),
	.Instruction(Instruction),
	.Data_Mem_Address(Data_Mem_Address),
	.Data_Mem_WriteData(Data_Mem_WriteData),
	.MemWrite(MemWrite),
	.MemRead(MemRead),
	.DataMenoryOut(Mem_Data_OR_PCI_Data_To_Cpu),
	.PCI_MEM_Ctrl(PCI_MEM_Ctrl),
	.Hit(Hit)
);	

reg reg_PCI_MEM_Ctrl;//将PCI_MEM_Ctrl延时一个周期，用于在WB级控制最终的访问内存的输出
reg	 [31:0]	ReadDataFromAHB;	//从AHB中读出的数据
always @ (posedge i_clk) begin
    if(!i_rst_n) reg_PCI_MEM_Ctrl<='b0;
    else reg_PCI_MEM_Ctrl<=PCI_MEM_Ctrl;
end  
assign Mem_Data_OR_PCI_Data_To_Cpu =(reg_PCI_MEM_Ctrl == 0)? DataMenoryOut : ReadDataFromAHB;
///////////////////////////////////////////////////////////////////////////////
//程序存储器///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
ram_ins InstructionMemory(
	.addr_ins(Address_Ins),
	.data_ins(Instruction)
);
///////////////////////////////////////////////////////////////////////////////
//数据存储器////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
ram_data DataMemory( 
	.clk_data(i_clk),
	.address(Data_Mem_Address),
	.Writedata(Data_Mem_WriteData),
	.MemWrite(MemWrite&~PCI_MEM_Ctrl),//写使能
	.MemRead(MemRead&~PCI_MEM_Ctrl),//读使能
	.ReadData(DataMenoryOut)
);

assign Testled[7] = i_clk;
assign Testled[6] = PCI_MEM_Ctrl;
assign Testled[5] = MemWrite;
assign Testled[4] = MemRead;
assign Testled[0] = Data_Mem_Address[31];
assign Testled[1] = Data_Mem_Address[31];

reg  [31:0] WriteDataToAHB;		//向AHB总线写入的数据

always@(posedge i_clk)
	begin
		if(!i_rst_n) WriteDataToAHB<=32'd0;
		else	WriteDataToAHB<=Data_Mem_WriteData;
	end
wire	Read_Write;
assign	Read_Write=(MemWrite==1)?1'b1:1'b0;

AHB_slaveMux #(
			.UART_BSP_RATE(UART_BSP_RATE),
			.CLK_PERIORD(CLK_PERIORD)
	 ) AHB_slaveMux_inst(	
			.clk(i_clk),
			.rst_n(i_rst_n),
			.HSEL(PCI_MEM_Ctrl),
			.addr(Data_Mem_Address),
			.Read_Write(Read_Write),		//0：表示读取，1：表示写数据
			.H_WriteData(WriteDataToAHB),
			.HTRANS(2'b11),   		//例化时直接设为11
			.HSIZE(3'b111), 			//例化时直接设为111
			.HPROT(4'b1111),     		//例化时直接设为1111
			.HBURST(3'b000),
			
			.S_ReadData(ReadDataFromAHB),		//从机中读取出的数据			
			.HREADYOUT(),
			.HRESP(),			//从机应答判决	

			.Key_press(Key_press),
			.led(led),
			.hex_0(hex_0),
			.hex_1(hex_1),
			.hex_2(hex_2),
			.hex_3(hex_3),
			.hex_dp(hex_dp),
			.i_rx_pin(i_rx_pin),
			.o_tx_pin(o_tx_pin)
);

endmodule
