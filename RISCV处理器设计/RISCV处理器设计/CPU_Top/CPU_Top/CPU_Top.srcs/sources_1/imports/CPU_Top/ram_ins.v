module ram_ins(
		input  [31:0]	 addr_ins,
		output [31:0] 	 data_ins
);
	parameter width = 6;	
	reg    [31:0]   Ram_Ins[width:0];    	
	integer          i;   
    
	
initial  
	begin  
		$readmemb("G:/verilog project/CPU_Top/initial_InstructionMemory.txt",Ram_Ins);//加载二进制  
		//$readmemh ("initial_InstructionMemory.mif",Mem);加载16进制文件
		//$readmemb("<数据文件名>",<存储器名>,<起始地址>,<终止地址>);
	end  
		

 assign data_ins = Ram_Ins[addr_ins>>2];//ram_Ins为什么定义256位宽，为什么addr_ins要右移两位
/* always@(*)
    begin
		for(i=0;i<=width;i=i+1)
			data_ins[i] = Ram_Ins[addr_ins];
	end */
	
endmodule