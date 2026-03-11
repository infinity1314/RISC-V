module ram( 
			input 	     clk_data,
            input [31:0] address,
            input [31:0] Writedata,
            input        MemWrite,//写使能
            input 		 MemRead,//读使能
            
            input [3:0] a,
            input [3:0] b,
            output  reg[31:0] ReadData,
            output    [3:0] sum
        );   
        
wire cout;
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

//assign {cout,sum}=a+b+cin;
//assign {cout,sum}=a+b+cin;

always @(posedge clk_data)//输出有一个周期延时
 begin
	if(MemRead)  begin
		if(address == 3) 
			ReadData <={27'b0,cout,sum};
		else	ReadData <= Data_Memory[address];
    end
 end
 assign a= Data_Memory[1][3:0];
 assign b= Data_Memory[2][3:0];
//直接输出，不延时
//assign ReadData = (MemRead==1'b0)?1'bz: Data_Memory[address];
my_4adder u5(
.a(a),
.b(b),
.s(sum),
.ci(0),
.cout(cout)
); 
endmodule