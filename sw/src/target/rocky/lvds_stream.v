module lvds_stream(
   input wire vs,
	input wire hs,
	input wire de,
	input	wire [23:0]		lvds_in,
	output wire [27:0]		lvds_out);
	
//	wire [27:0] lvds_out;
//	wire [23:0] lvds_in;

/*	
	assign lvds_out[27:0] = {lvds_in[22], lvds_in[23], lvds_in[14], lvds_in[15], lvds_in[6],lvds_in[7], 1'b0, 
							lvds_in[2], lvds_in[3], lvds_in[4], lvds_in[5], hs, vs, de,
							lvds_in[9],lvds_in[10],lvds_in[11],lvds_in[12],lvds_in[13], lvds_in[0],lvds_in[1],
							lvds_in[16],lvds_in[17],lvds_in[18],lvds_in[19],lvds_in[20],lvds_in[21], lvds_in[8]};

	assign lvds_out[27:0] = {
							lvds_in[16],lvds_in[17],lvds_in[18],lvds_in[19],lvds_in[20],lvds_in[21], lvds_in[8],
							lvds_in[9],lvds_in[10],lvds_in[11],lvds_in[12],lvds_in[13], lvds_in[0],lvds_in[1],
							lvds_in[2], lvds_in[3], lvds_in[4], lvds_in[5], hs, vs, de,
							lvds_in[22], lvds_in[23], lvds_in[14], lvds_in[15], lvds_in[6],lvds_in[7], 1'b0 
							};					
		

	assign lvds_out[27:0] = { 1'b0,lvds_in[7],lvds_in[6],lvds_in[15],lvds_in[14], lvds_in[23],lvds_in[22] ,   
							de,vs,hs,lvds_in[5],lvds_in[4],lvds_in[3],lvds_in[2],      
							lvds_in[1],lvds_in[0],lvds_in[13],lvds_in[12],lvds_in[11],lvds_in[10],lvds_in[9], 
							lvds_in[8],lvds_in[21],lvds_in[20],lvds_in[19],lvds_in[18],lvds_in[17],lvds_in[16]};

	assign lvds_out[27:0] = { 
							lvds_in[8],lvds_in[21],lvds_in[20],lvds_in[19],lvds_in[18],lvds_in[17],lvds_in[16],
							lvds_in[1],lvds_in[0],lvds_in[13],lvds_in[12],lvds_in[11],lvds_in[10],lvds_in[9],
							de,vs,hs,lvds_in[5],lvds_in[4],lvds_in[3],lvds_in[2],    
							1'b0,lvds_in[7],lvds_in[6],lvds_in[15],lvds_in[14], lvds_in[23],lvds_in[22] 
						  
	assign lvds_out[27:0] = { lvds_in[23],lvds_in[22] ,1'b0,lvds_in[7],lvds_in[6],lvds_in[15],lvds_in[14],    
							lvds_in[3],lvds_in[2],de,vs,hs,lvds_in[5],lvds_in[4],      
							lvds_in[10],lvds_in[9],lvds_in[1],lvds_in[0],lvds_in[13],lvds_in[12],lvds_in[11], 
							lvds_in[17],lvds_in[16],lvds_in[8],lvds_in[21],lvds_in[20],lvds_in[19],lvds_in[18]};							 
*/
	assign lvds_out[27:0] = { 1'b0,lvds_in[7],lvds_in[6],lvds_in[15],lvds_in[14],lvds_in[23],lvds_in[22] ,    
							de,vs,hs,lvds_in[5],lvds_in[4], lvds_in[3],lvds_in[2],     
							lvds_in[1],lvds_in[0],lvds_in[13],lvds_in[12],lvds_in[11], lvds_in[10],lvds_in[9],
							lvds_in[8],lvds_in[21],lvds_in[20],lvds_in[19],lvds_in[18],lvds_in[17],lvds_in[16]};					
			
	
	/*				
		assign lvds_out[27:0] = { 7'b0 ,   
							2'b0, 1'b1,4'b0,      
							7'b0, 
							7'b0};					
		*/	
endmodule
