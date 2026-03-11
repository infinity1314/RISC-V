module Ram_Reg32( 
			input 		 clk_res	,            
			input [4:0]  ReadReg1	,
            input [4:0]  ReadReg2	,
            input [4:0]  WriteReg	,//寄存器写地址
            input [31:0] Writedata	,//寄存器写数据	
            input   	 en_RegWrite,//寄存器写使能
            output[31:0] ReadData1	,
            output[31:0] ReadData2	
        ); 
		
 parameter width = 31; 
 
reg [31:0] Reg32 [width:0];

integer i;

//初始化ROM
initial  
	begin 
		for(i=0;i<=width;i=i+1)
		Reg32[i]<='b0;
	end  
	   
 always@(posedge clk_res)
    begin 
      if(en_RegWrite & (WriteReg!=5'd0))
          Reg32[WriteReg] <= Writedata;
    end  
 
 assign ReadData1 = (ReadReg1==5'd0)?32'd0:Reg32[ReadReg1];
 assign ReadData2 = (ReadReg2==5'd0)?32'd0:Reg32[ReadReg2];
 
endmodule
