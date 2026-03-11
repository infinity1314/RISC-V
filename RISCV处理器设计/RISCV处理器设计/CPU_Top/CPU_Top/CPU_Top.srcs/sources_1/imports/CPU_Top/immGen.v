module immGen (
            input [31:0]  Instruction,
            output [31:0] imm
        );   
reg [31:0]imm_reg;

assign imm=imm_reg;
always@(*) begin 
			case(Instruction[6:0])
			7'b011_0111:begin 
						if(Instruction[31]==1'b0) imm_reg={12'd0,Instruction[31:12]};
						else if(Instruction[31]==1'b1)imm_reg={12'hfff,Instruction[31:12]}; 
						end
			7'b001_0111:begin 
						if(Instruction[31]==1'b0) imm_reg={12'd0,Instruction[31:12]};
						else if(Instruction[31]==1'b1)imm_reg={12'hfff,Instruction[31:12]}; 
						end
			7'b110_1111:begin
						if(Instruction[31]==1'b0)
							imm_reg={12'd0,Instruction[31],Instruction[19:12],Instruction[20],Instruction[30:21]};
						else if(Instruction[31]==1'b1)
							imm_reg={12'hfff,Instruction[31],Instruction[19:12],Instruction[20],Instruction[30:21]};
						end
			7'b110_0111:begin 
						if(Instruction[31]==1'b0)imm_reg={20'd0,Instruction[31:20]};
						else if(Instruction[31]==1'b1)imm_reg={20'hff_fff,Instruction[31:20]};
						end
			7'b110_0011:begin 
						if(Instruction[31]==1'b0) 
							imm_reg={20'd0,Instruction[31],Instruction[7],Instruction[30:25],Instruction[11:8]};
						else if(Instruction[31]==1'b1) 
							imm_reg={20'hff_fff,Instruction[31],Instruction[7],Instruction[30:25],Instruction[11:8]};
						end
			7'b000_0011:begin 
						if(Instruction[31]==1'b0) imm_reg={20'd0,Instruction[31:20]};
						else if(Instruction[31]==1'b1) imm_reg={20'hff_fff,Instruction[31:20]};
						end						
			7'b010_0011:begin 
						if(Instruction[31]==1'b0) imm_reg={20'd0,Instruction[31:25],Instruction[11:7]};
						else if(Instruction[31]==1'b1) imm_reg={20'hff_fff,Instruction[31:25],Instruction[11:7]};
						end
			7'b001_0011:begin if((Instruction[14:12]==3'b000)||(Instruction[14:12]==3'b010))
								begin if(Instruction[31]==1'b0)imm_reg={20'd0,Instruction[31:20]};
									  else if(Instruction[31]==1'b1)imm_reg={20'hff_fff,Instruction[31:20]};
								end
							  else imm_reg={20'd0,Instruction[31:20]};
						end
			7'b011_0011:imm_reg=32'd0;
			default:imm_reg=32'd0;
			endcase
end



endmodule