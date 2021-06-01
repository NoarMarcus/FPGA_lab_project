//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// System-Verilog Alex Grinshpun May 2018
// New coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2019 


module	trans_platform_object	(	
					input		logic	clk,
					input		logic	resetN,
					input 	logic	[10:0] pixelX,// current VGA pixel 
					input 	logic	[10:0] pixelY,
					input		logic DrawThisSquare,
					
					output	logic	drawingRequest // indicates pixel inside the bracket
);
localparam int topLeftX = 10;
localparam int topLeftY = 80;
parameter  int OBJECT_WIDTH_X = 60;
parameter  int OBJECT_HEIGHT_Y = 10;
localparam int width_of_subSquare = 90;
localparam int hight_of_subSquare = 90;
parameter  logic [7:0] OBJECT_COLOR = 8'h5b ; 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// bitmap  representation for a transparent pixel 
 
int rightX ; //coordinates of the sides  
int bottomY ;
logic insideBracket ; 

//////////--------------------------------------------------------------------------------------------------------------=
// Calculate object right  & bottom  boundaries
assign rightX	= (topLeftX + OBJECT_WIDTH_X);
assign bottomY	= (topLeftY + OBJECT_HEIGHT_Y);


//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		drawingRequest	<=	1'b0;
	end
	else begin 
	
//		if ( (pixelX  >= topLeftX) &&  (pixelX < rightX) 
//			&& (pixelY  >= topLeftY) &&  (pixelY < bottomY) ) // test if it is inside the rectangle 

		//this is an example of using blocking sentence inside an always_ff block, 
		//and not waiting a clock to use the result  
		insideBracket  = 	 ( ((pixelX) % width_of_subSquare  >= topLeftX) &&  ((pixelX) % width_of_subSquare < rightX) // ----- LEGAL BLOCKING ASSINGMENT in ALWAYS_FF CODE 
						   && (pixelY %  hight_of_subSquare  >= topLeftY) &&  (pixelY %hight_of_subSquare < bottomY) )  ; 
		
		if (insideBracket ) // test if it is inside the rectangle 
		begin
			drawingRequest <= 1'b1 ;
		end 
		
		else begin
			drawingRequest <= 1'b0 ;// transparent color 
		end 
	end
end 
endmodule 