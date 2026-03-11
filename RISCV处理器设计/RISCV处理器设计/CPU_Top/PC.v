module PC(
   input    clk,
   input    rest,
   input    [0:0]sel,
   input    [31:0]  source,
   input    [0:0]  en,
   output   reg [31:0] pc,
   output   reg [31:0] pcadd4
);
   reg   [31:0]  result;
   always  @ (*)
    begin
	 case (sel)
                1'b1: 
                  begin 				
				   result<=source;
				  end
				1'b0:
				  begin 
				   result<=pc+32'd4;
                  end 
			    default ;
			endcase   
	end   
always  @ (posedge  clk  or   negedge rest)
  if(!rest)
    begin
     pc<=32'd0;
     pcadd4<=32'd0;
	end
  else  if(en)
    begin 
     pc<=result;
     pcadd4<=result+32'd4;
   end
endmodule
