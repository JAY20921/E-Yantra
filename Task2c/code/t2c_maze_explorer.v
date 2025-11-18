// Task 2C - MazeSolver Bot

/*
# Team ID:         4683
# Theme:           Mazesolver
# Author List:     Jay Lade, Nitin Dhankar
# Filename:        t2c_maze_explorer.v
# File Description: Solving maze and exploring dead ends using a hybrid
#                  wall-following and exploration algorithm.
*/

module t2c_maze_explorer (
    input clk,
    input rst_n,
    input left, mid, right, // 0 - no wall, 1 - wall
    output reg [2:0] move
);

/*

| cmd | move  | meaning   |
|-----|-------|-----------|
| 000 | 0     | STOP      |
| 001 | 1     | FORWARD   |
| 010 | 2     | LEFT      |
| 011 | 3     | RIGHT     | 
| 100 | 4     | U_TURN    |

START POS   : 4,0
EXIT POS    : 4,8
DEADENDS    : 9

*/
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

/*
This logic implements a hybrid strategy:
1. By default, it follows a "Left-Hand Rule" (Prioritize L, then F, then R).
2. Every 8 steps, it switches its priority to a "Right-Hand Rule"
   (Prioritize R, then F, then L).
This is intended to force the bot to explore paths that a simple
wall-follower might miss, which is necessary to find all dead ends.
*/

// Internal FSM state for 2-cycle move decision
    reg [1:0] state;
    localparam SENSE    = 2'b00;
    localparam DECIDE   = 2'b01;
    
    // Simple counter to occasionally explore right side
    // This logic is restored from the original user code.
    reg [3:0] step_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            move  <= 3'b000; // STOP
            state <= SENSE;
            step_count <= 4'b0000; // Reset the counter
        end else begin
            case (state)
                SENSE: begin
                    // Wait for fresh sensor data
                    // We just transition to DECIDE state to make the
                    // decision on the next clock cycle (total 2 cycles).
                    state <= DECIDE;
                end
                
                DECIDE: begin
                    // Increment the step counter
                    step_count <= step_count + 1;
                    
                    // Occasionally prefer right turns to explore different paths
                    // This happens every 8 steps
                    if (step_count[2:0] == 3'b111) begin // Every 8th step
                        // Prioritize RIGHT
                        if(right == 1'b0) begin
                            move <= 3'b011; // RIGHT
                        end else if(mid == 1'b0) begin
                            move <= 3'b001; // FORWARD
                        end else if(left == 1'b0) begin
                            move <= 3'b010; // LEFT
                        end else begin
                            move <= 3'b100; // U-TURN (dead-end)
                        end
                    end else begin
                        // Normal left-hand rule
                        // Prioritize LEFT
                        if(left == 1'b0) begin
                            move <= 3'b010; // LEFT
                        end else if(mid == 1'b0) begin
                            move <= 3'b001; // FORWARD
                        end else if(right == 1'b0) begin
                            move <= 3'b011; // RIGHT
                        end else begin
                            move <= 3'b100; // U-TURN (dead-end)
                        end
                    end
                    
                    state <= SENSE; // Go back to SENSE state for next clock cycle
                end
                
                default: begin
                    move <= 3'b000; // Fail-safe STOP
                    state <= SENSE;
                end
            endcase
        end
    end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule