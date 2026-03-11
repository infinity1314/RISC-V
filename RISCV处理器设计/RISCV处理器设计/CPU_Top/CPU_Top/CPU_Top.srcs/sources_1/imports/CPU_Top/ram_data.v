module ram_data( 
			input 	     clk_data,
            input [31:0] address,
            input [31:0] Writedata,
            input        MemWrite,//写使能
            input 		 MemRead,//读使能
            output  reg[31:0] ReadData
            
        );   

reg [31:0] Data_Memory[255:0];

integer i;
initial  
	begin 
		for(i=0;i<=255;i=i+1)
		Data_Memory[i]<='b0;
	end  

always @(posedge clk_data)
 begin
	if(MemWrite)
		Data_Memory[address] <= Writedata;
 end

always @(posedge clk_data)//输出有一个周期延时
 begin
	if(MemRead)
		ReadData <= Data_Memory[address];
 end
//直接输出，不延时
//assign ReadData = (MemRead==1'b0)?1'bz: Data_Memory[address];
 
endmodule