/*
# Team ID:          4683
# Theme:            Mazesolver
# Author List:      Jay Lade, Nitin Dhankar, Mohd Haisam Khan, Gottipati Vishnu Vardhan Babu
# Filename:         t1b_ultrasonic.v
# File Description: Verilog module for interfacing HC-SR04 ultrasonic sensor to measure distance 
#                   and detect presence of an object using a 5-state FSM.
*/

///*
	//Module HC_SR04 Ultrasonic Sensor
	//
	//This module will detect objects present in front of the range, and give the distance in mm.
	//
	//Input:  clk_50M - 50 MHz clock
	//        reset   - reset input signal (Use negative reset)
	//        echo_rx - receive echo from the sensor
	//
	//Output: trig    - trigger sensor for the sensor
	//        op     -  output signal to indicate object is present.
	//        distance_out - distance in mm, if object is present.
	//*/
	//
	//// module Declaration
	module t1b_ultrasonic(
		 input clk_50M, reset, echo_rx,
		 output reg trig,
		 output op,
		 output wire [15:0] distance_out
	);

	initial begin
		 trig = 0;
	end
	//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////
		
	// -------------------------------------------------------------------------
	// Internal Variable Declarations
	// -------------------------------------------------------------------------
		
	reg [2:0] state;                    // FSM state register
	reg detection_flag;                 // Indicates if object detected
	reg [15:0] measured_distance;       // Calculated distance in mm
	reg [19:0] echo_counter = 0;        // Counts echo pulse duration
	reg [19:0] delay_counter = 0;       // General-purpose delay counter
		
	// FSM States
	localparam DELAY               = 0,  // Initial wait before trigger
	           TRIG_PHASE          = 1,  // Generate trigger pulse
	           MONITOR             = 2,  // Measure echo pulse duration
	           OBJECT_DETERMINATION= 3,  // Decide if object detected
	           FINISHED            = 4;  // Wait before next cycle
		
	// -------------------------------------------------------------------------
	// Initialization of internal variables
	// -------------------------------------------------------------------------
	initial begin 
		state             = DELAY;
		detection_flag    = 0;
		measured_distance = 0;
		echo_counter      = 0; 
		delay_counter     = 0;
	end	
		
	// -------------------------------------------------------------------------
	// Main FSM Logic
	// -------------------------------------------------------------------------
	always @(posedge clk_50M) begin
		if (reset == 0) begin
			// Reset all variables
			state             <= DELAY;
			detection_flag    <= 0;
			measured_distance <= 0;
			echo_counter      <= 0;
			delay_counter     <= 0;
			trig              <= 0;
		end
			
		else begin 
			case (state) 
					
				// -------------------------------------------------------------
				// Stage 1: Initial Delay before sending trigger
				// -------------------------------------------------------------
				DELAY: begin
					if (delay_counter != 50) begin
						delay_counter <= delay_counter + 1;
					end
					else begin 
						delay_counter <= 0;
						state <= TRIG_PHASE;
					end
				end
					
				// -------------------------------------------------------------
				// Stage 2: Send Trigger Pulse (approx. 10 µs)
				// -------------------------------------------------------------
				TRIG_PHASE: begin
					trig <= 1;
					if (delay_counter != 500) begin
						delay_counter <= delay_counter + 1;
					end
					else begin 
						delay_counter <= 0;
						state <= MONITOR;
						trig <= 0;
					end
				end
					
				// -------------------------------------------------------------
				// Stage 3: Monitor Echo Pulse Duration
				// -------------------------------------------------------------
				MONITOR: begin
					if (echo_rx) begin 
						// Count while echo signal is high
						echo_counter <= echo_counter + 1;
					end
					else begin 
						// Compute distance once echo goes low
						measured_distance <= (echo_counter * 34) / 10000;	
						echo_counter <= 0;
						state <= OBJECT_DETERMINATION;
					end
					delay_counter <= delay_counter + 1;
				end
					
				// -------------------------------------------------------------
				// Stage 4: Determine if object is within detection range
				// -------------------------------------------------------------
				OBJECT_DETERMINATION: begin
					if (measured_distance <= 16'd70) begin
						detection_flag <= 1;
					end
					else begin 
						detection_flag <= 0;
					end
					delay_counter <= delay_counter + 1;
					state <= FINISHED;
				end
					
				// -------------------------------------------------------------
				// Stage 5: Wait before next trigger cycle
				// -------------------------------------------------------------
				FINISHED: begin
					if (delay_counter != 600001) begin
						delay_counter <= delay_counter + 1;
					end
					else begin 
						delay_counter <= 0;
						state <= DELAY;
					end
				end
			endcase
		end 
	end	
		
	// -------------------------------------------------------------------------
	// Output Assignments
	// -------------------------------------------------------------------------
	assign distance_out = measured_distance;  // Distance output in mm
	assign op = detection_flag;               // Object presence flag

	//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

	endmodule
