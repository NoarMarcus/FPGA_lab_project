//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2019 

module	Draw_control	(	
//		--------	Clock Input	 	
					input logic	clk,
					input logic	resetN, 
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
//					Drawing in this subSquare
					output logic Draw_platform_here  	 
);
								
localparam int Number_of_Rows = 5;
localparam int Number_of_columns = 7;
localparam int width_of_subSquare = 90;
localparam int hight_of_subSquare = 90;
bit  [(Number_of_Rows-1):0] [(Number_of_columns-1):0] subSquare_Draw ={
//Defining if the object should be drawn in this subSquare
	7'b1111111,
	7'b0000001,
	7'b0,
	7'b0,
	7'b0
};
always_ff@( posedge clk or negedge resetN) 
	begin

		Draw_platform_here <= subSquare_Draw[pixelY / hight_of_subSquare][(pixelX) / width_of_subSquare];
	
	end
endmodule


