`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
//////////////////////////////////////////////////////////


module led(input    [31:0]       Data_Mem_Address,
            input   [31:0]       Data_Mem_WriteData,
            input                sys_clk,
            input                sys_rst_n,
            output  reg [7:0]   led
    );
    
parameter local=32'b10_0000000000_0000000000_0000000000;    
    

    
 always @( posedge sys_clk or negedge sys_rst_n  )
    if(!sys_rst_n)begin
        led<='b0000_0000;
        end
    else if(Data_Mem_Address==local)
        led<=Data_Mem_WriteData[7:0];

endmodule
