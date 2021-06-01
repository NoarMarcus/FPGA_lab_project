
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2020 


module	game_controller_all	(	
			input		logic	clk,
			input		logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_bumpy,
			input	logic	drawing_request_wall,
			input logic drawing_request_platform,
			input logic drawing_request_transplatform,
		
			
			output logic collision_bumpy_platform,
			output logic collision_bumpy_transplatform,
			output logic collision_bumpy_wall,	// active in case of collision between two objects
			output logic SingleHitPulse	// critical code, generating A single pulse in a frame 
);

assign collision_bumpy_wall = (drawing_request_bumpy & drawing_request_wall );
assign collision_bumpy_platform = (drawing_request_bumpy & drawing_request_platform) ; 
assign collision_bumpy_transplatform = (drawing_request_bumpy & drawing_request_transplatform);
logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
	end 
	else begin 

			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) 
				flag = 1'b0 ; // reset for next time 
			if ( (collision_bumpy_wall | collision_bumpy_platform )  && (flag == 1'b0)) begin 
				flag	<= 1'b1; // to enter only once 
				SingleHitPulse <= 1'b1 ; 
			end ; 
	end 
end

endmodule
