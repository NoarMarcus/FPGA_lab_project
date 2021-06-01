//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018


module	Bumpy_Movment_Logic	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	NX_Left, 	//Key[2]
					input	logic	NX_Right, //Key[1]
					input	logic	NJump, 	//Key[3] 
					input logic collision_platform,//1 if bumpy hits a platform
					input logic collision_wall,//1 if bumpy hits the wall	
					input logic collision_transplatform,	
					input	logic	[3:0] HitEdgeCode, //one bit per edge 
				
				
					output	logic signed 	[10:0]	topLeftX,// output the top left corner 
					output	logic signed	[10:0]	topLeftY
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 225;
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 0;
parameter int INITIAL_Y_SPEED = 0;
parameter int Y_ACCEL = 6;
parameter int X_speed_after_pressed = 176 ;
parameter int Y_speed_after_pressed = 94 ;
parameter int Bumpy_Height = 32;

const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to work with integers in high resolution 
// we do all calulations with topLeftX_FixedPoint  so we get a resulytion inthe calcuatuions of 1/64 pixel 
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n 
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;


int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;
int JumpFlag = 0;

//////////--------------------------------------------------------------------------------------------------------------=
//  calculation x Axis speed 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
		Xspeed	<= INITIAL_X_SPEED;
	else	begin
		//if (NX_Left == 1'b0 & startOfFrame == 1'b1 & Xspeed == 0)
			//Xspeed <= X_speed_after_pressed;
			
		//else if (NX_Right == 1'b0 & startOfFrame == 1'b1 & Xspeed == 0)
			//Xspeed <= -X_speed_after_pressed;
		if (collision_platform == 1'b1)
			begin
			
				if (NX_Left == 1'b0)
				begin
					Xspeed <= X_speed_after_pressed;
				end
				
				else if (NX_Right == 1'b0)
				begin
					Xspeed <= -X_speed_after_pressed;
				end
				
				else
				Xspeed <= 0;
				
				
				
		if (collision_transplatform == 1'b1)	
	begin	
				if (NX_Left == 1'b0 && JumpFlag == 1)
				begin
					Xspeed <= X_speed_after_pressed;
				end
				
				else if (NX_Right == 1'b0 && JumpFlag == 1)
				begin
					Xspeed <= -X_speed_after_pressed;
				end
				
				else
				Xspeed <= 0;
	end
				
			if (NJump == 1'b0)
				JumpFlag <= 1;
					
			end
			
			
			// colision Calcultaion 
			
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


		if (collision_wall && HitEdgeCode [3] == 1 )   // hit left border of brick  
				if (Xspeed < 0) // while moving right
						Xspeed <= -Xspeed ; 
			
			if (collision_wall && HitEdgeCode [1] == 1 )   // hit right border of brick  
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
			
		else if (startOfFrame == 1'b1) 
				Yspeed <= Yspeed  + Y_ACCEL; // deAccelerate : slow the speed down every clock tick 
		else if (collision_platform == 1'b1 )
				begin
					if (NJump == 1'b0 )
						Yspeed <= -topLeftY;
					
					else if (Yspeed < 0 )
						Yspeed <= -Y_speed_after_pressed;
						
					else if (Yspeed > 0 )
						Yspeed <= -Yspeed;
						
				end
		else if (collision_transplatform == 1'b1  )
				begin
				if ((NX_Right == 1'b0 || NX_Left == 1'b0) && JumpFlag == 1 )
					Yspeed <= -Y_speed_after_pressed;
						
				end
				
					
	// colision Calcultaion 
				
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
		
		if (startOfFrame == 1'b1) 
		begin // perform  position integral only 30 times per second 

			topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; 
			topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed; 

		end

	end
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    

endmodule
