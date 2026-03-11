module Ram_Reg32( 
			input 		 clk_res	,            
			input [4:0]  ReadReg1	,
            input [4:0]  ReadReg2	,
            input [4:0]  WriteReg	,////¼Ä´æÆ÷Ğ´µØÖ·
            input [31:0] Writedata	,////¼Ä´æÆ÷Ğ´Êı¾İ		
            input   	 en_RegWrite,//¼Ä´æÆ÷Ğ´Ê¹ÄÜ
            output[31:0] ReadData1	,
            output[31:0] ReadData2	
        ); 
		
 parameter width = 31; 
 
reg [31:0] Reg32 [width:0];

integer i;

//³õÊ¼»¯ROM
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
