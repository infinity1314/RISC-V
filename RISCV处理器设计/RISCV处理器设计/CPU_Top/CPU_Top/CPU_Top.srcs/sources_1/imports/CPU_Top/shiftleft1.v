
module shiftleft1 (
            input [31:0]  source1,
            output[31:0]   result
        );   
       
  assign     result=(source1<<1);
endmodule  