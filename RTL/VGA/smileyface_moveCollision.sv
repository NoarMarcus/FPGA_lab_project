//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018


module	smileyface_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	X_direction,  //change the direction in X 
					input	logic	toggleY, 	//toggle the y direction 
					input logic collision,  //collision if smiley hits an object
					input	logic	[3:0] HitEdgeCode, //one bit per edge 

					output	 logic signed 	[10:0]	topLeftX,// output the top left corner 
					output	 logic signed	[10:0]	topLeftY
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 40;
parameter int INITIAL_Y_SPEED = 20;
parameter int Y_ACCEL = -10;

const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to work with integers in high resolution 
// we do all calulations with topLeftX_FixedPoint  so we get a resulytion inthe calcuatuions of 1/64 pixel 
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n 
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;


int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;


//////////--------------------------------------------------------------------------------------------------------------=
//  calculation x Axis speed 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
		Xspeed	<= INITIAL_X_SPEED;
	else 	begin
			
			
			// colision Calcultaion 
			
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


		if (collision && HitEdgeCode [3] == 1 )   // hit left border of brick  
				if (Xspeed < 0) // while moving right
						Xspeed <= -Xspeed ; 
			
			if (collision && HitEdgeCode [1] == 1 )   // hit right border of brick  
				if (Xspeed > 0 ) //  while moving left
					Xspeed <= -Xspeed ; 
			
				
	end
end


//////////--------------------------------------------------------------------------------------------------------------=
//  calculation Y Axis speed using gravity

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin 
		Yspeed	<= INITIAL_Y_SPEED;
	end 
	else begin
		if (toggleY)  
			Yspeed <= -Yspeed ; 
			
		if (startOfFrame == 1'b1) 
				Yspeed <= Yspeed  - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick 
			
					
	// colision Calcultaion 
			
		//hit bit map has  one bit per edge:  Left-Top-Right-Bottom	 

	
		if (collision && HitEdgeCode [2] == 1 )   // hit top border of brick  
				if (Yspeed < 0) // while moving up
						Yspeed <= -Yspeed ; 
			
			if (collision && HitEdgeCode [0] == 1 )   // hit bottom border of brick  
				if (Yspeed > 0 ) //  while moving doun
					Yspeed <= -Yspeed ; 
		

	end
end

//////////--------------------------------------------------------------------------------------------------------------=
// position calculate 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
	end
	else begin
		
		if (startOfFrame == 1'b1) begin // perform  position integral only 30 times per second 

			topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; 

			if (X_direction==1'b0) //  while moving down
				topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed; 
			else 
				topLeftX_FixedPoint  <= topLeftX_FixedPoint - Xspeed; 



					
			end
	end
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
