`timescale 1ns/1ps

module tb;
    // set to 1 to enable debug prints
    parameter debug = 1;

    reg clk, rst_n;
    reg left, mid, right;
    wire [2:0] move;

    t2c_maze_explorer uut (
        .clk(clk),
        .rst_n(rst_n),
        .left(left),
        .mid(mid),
        .right(right),
        .move(move)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // map: north(3) east(2) south(1) west(0)
    reg [3:0] map_data [0:80];
    reg [1:0] bot_facing;
    reg [7:0] bot_pos;

    // dead ends (store indices) and bit vector for visited flags
    reg [7:0] dead_ends [0:11];
    reg [11:0] dead_end_bits;
    integer n_dead;
    integer px, py, qx, qy;

    function [7:0] facing_char;
        input [1:0] facing;
        begin
            case (facing)
                2'b00: facing_char = "N";
                2'b01: facing_char = "E";
                2'b10: facing_char = "S";
                2'b11: facing_char = "W";
                default: facing_char = "?";
            endcase
        end
    endfunction

    function [2:0] get_walls;
        input [3:0] map;
        input [1:0] facing;
        begin
            case (facing)
                2'b00: get_walls = {map[0], map[3], map[2]}; // North
                2'b01: get_walls = {map[3], map[2], map[1]}; // East
                2'b10: get_walls = {map[2], map[1], map[0]}; // South
                2'b11: get_walls = {map[1], map[0], map[3]}; // West
                default: get_walls = 3'b111;
            endcase
        end
    endfunction

    integer delta [0:3];

    integer idx, j;
    integer visited_count;
    integer new_pos_int;

    initial begin
        // initialize maze map
            delta[0] = -9;
            delta[1] =  1;
            delta[2] =  9;
            delta[3] = -1;
            map_data[0]= 4'b1011;
            map_data[1]= 4'b1000;
            map_data[2]= 4'b1000;
            map_data[3]= 4'b1100;
            map_data[4]= 4'b0001;
            map_data[5]= 4'b1110;
            map_data[6]= 4'b1001;
            map_data[7]= 4'b1010;
            map_data[8]= 4'b1100;
            map_data[9]= 4'b1001;
            map_data[10]= 4'b0110;
            map_data[11]= 4'b0111;
            map_data[12]= 4'b0101;
            map_data[13]= 4'b0101;
            map_data[14]= 4'b1001;
            map_data[15]= 4'b0110;
            map_data[16]= 4'b1001;
            map_data[17]= 4'b0100;
            map_data[18]= 4'b0011;
            map_data[19]= 4'b1110;
            map_data[20]= 4'b1001;
            map_data[21]= 4'b0110;
            map_data[22]= 4'b0011;
            map_data[23]= 4'b0110;
            map_data[24]= 4'b1001;
            map_data[25]= 4'b0110;
            map_data[26]= 4'b0101;
            map_data[27]= 4'b1001;
            map_data[28]= 4'b1010;
            map_data[29]= 4'b0110;
            map_data[30]= 4'b1001;
            map_data[31]= 4'b1010;
            map_data[32]= 4'b1100;
            map_data[33]= 4'b0101;
            map_data[34]= 4'b1101;
            map_data[35]= 4'b0101;
            map_data[36]= 4'b0011;
            map_data[37]= 4'b1000;
            map_data[38]= 4'b1100;
            map_data[39]= 4'b0011;
            map_data[40]= 4'b1100;
            map_data[41]= 4'b0101;
            map_data[42]= 4'b0011;
            map_data[43]= 4'b0110;
            map_data[44]= 4'b0101;
            map_data[45]= 4'b1011;
            map_data[46]= 4'b0100;
            map_data[47]= 4'b0101;
            map_data[48]= 4'b1101;
            map_data[49]= 4'b0101;
            map_data[50]= 4'b0011;
            map_data[51]= 4'b1010;
            map_data[52]= 4'b1100;
            map_data[53]= 4'b0101;
            map_data[54]= 4'b1001;
            map_data[55]= 4'b0110;
            map_data[56]= 4'b0001;
            map_data[57]= 4'b0010;
            map_data[58]= 4'b0010;
            map_data[59]= 4'b1010;
            map_data[60]= 4'b1100;
            map_data[61]= 4'b0011;
            map_data[62]= 4'b0110;
            map_data[63]= 4'b0101;
            map_data[64]= 4'b1011;
            map_data[65]= 4'b0110;
            map_data[66]= 4'b1001;
            map_data[67]= 4'b1100;
            map_data[68]= 4'b1001;
            map_data[69]= 4'b0110;
            map_data[70]= 4'b1001;
            map_data[71]= 4'b1100;
            map_data[72]= 4'b0011;
            map_data[73]= 4'b1010;
            map_data[74]= 4'b1010;
            map_data[75]= 4'b0110;
            map_data[76]= 4'b0101;
            map_data[77]= 4'b0011;
            map_data[78]= 4'b1010;
            map_data[79]= 4'b0110;
            map_data[80]= 4'b0111;

        // find dead ends 
        n_dead = 0;
        for (idx = 0; idx < 81; idx = idx + 1) begin
            case (map_data[idx])
                4'b0111, 4'b1011, 4'b1101, 4'b1110: begin
                    dead_ends[n_dead] = idx;
                    n_dead = n_dead + 1;
                end
            endcase
        end

        dead_end_bits = 12'b0;

        if (debug) begin
            $display("Dead ends at positions:");
            for (idx = 0; idx < n_dead; idx = idx + 1)
                $write("%0d ", dead_ends[idx]);
            $display("\n");
        end

        // initial conditions for bot
        bot_facing = 2'b00; // north
        bot_pos = 7'd76;    // starting position

        rst_n = 0; #20;
        rst_n = 1; #20;

        // Main simulation loop (we use idx as step counter too)
        for (idx = 0; idx < 250; idx = idx + 1) begin
            // compute walls relative to facing and present them to UUT
            {left, mid, right} = get_walls(map_data[bot_pos], bot_facing);
            #20; // wait for move to be computed by the FSM

            if (debug) begin
                px = bot_pos % 9; // column (x)
                py = bot_pos / 9; // row (y)
                $display("Step %0d: Pos=[%0d, %0d] Facing=%s Walls=%b Move=%b",idx, px, py, facing_char(bot_facing), {left, mid, right}, move);
                
            end

            // check maze exit: at position 3 with a forward move matching facing
            // move codes in original TB:
            // north: 001, east:010, west:011 (south not handled as exit in original)
            if (bot_pos == 7'd4) begin
                if ((bot_facing == 2'b00 && move == 3'b001) ||
                    (bot_facing == 2'b01 && move == 3'b010) ||
                    (bot_facing == 2'b11 && move == 3'b011)) begin

                    $display("Maze exited successfully!");
                    $display("steps taken: %0d", idx);

                    visited_count = 0;
                    $display("Dead end visit bits:");
                    for ( j = 0; j < n_dead; j = j + 1) begin
                        if (dead_end_bits[j]) begin 
                            visited_count = visited_count + 1;
                            $display("Position %0d", dead_ends[j]);
                        end
                    end
                    $display("Total dead ends visited: %0d out of %0d", visited_count, n_dead);
						  if(visited_count == n_dead)begin
								$display("all dead ends explored.");
						  end
						  else $display("some dead ends not explored.");
                    $stop;
                end
            end

            case (move)
                3'b010: begin // LEFT
                    bot_facing = bot_facing - 1; // 2-bit wrap-around
                end
                3'b011: begin // RIGHT
                    bot_facing = bot_facing + 1;
                end
                3'b100: begin // U_TURN
                    bot_facing = bot_facing + 2;
                    // mark current position as visited dead-end if it is one
                    for (j = 0; j < n_dead; j = j + 1) begin
                        if (bot_pos == dead_ends[j]) begin
                            dead_end_bits[j] = 1'b1;
                        end
                    end
                end
                default: begin
                    // no turning
                end
            endcase

            // move forward if required (move != 000)
            if (move != 3'b000) begin
                // front wall bit index = 3 - facing (north->3, east->2, south->1, west->0)
                
                if (map_data[bot_pos][3 - bot_facing] == 1'b0) begin
                    // safe to move: compute new position using delta array
                    // integer new_pos_int;
                    new_pos_int = $signed(bot_pos) + delta[bot_facing];
                    // basic bounds check (shouldn't be needed with correct map)
                    if (new_pos_int < 0 || new_pos_int > 80) begin
                        px = bot_pos % 9; // column (x)
                        py = bot_pos / 9; // row (y)
                        qx = new_pos_int % 9; // column (x)
                        qy = new_pos_int / 9; // row (y)
                        $display("Invalid move or left maze from pos=[%0d, %0d] facing=%s (new=[%0d, %0d])", px, py, facing_char(bot_facing), qx, qy);
                        $stop;
                    end
                    bot_pos = new_pos_int;
                end
                else begin
                    px = bot_pos % 9; // column (x)
                    py = bot_pos / 9; // row (y)
                    $display("Hit a wall at position [%0d, %0d] facing %s!",px, py, facing_char(bot_facing));
                    $stop;
                end
            end
        end // for steps

        $display("Simulation ended without exiting the maze.");
        $stop;
    end
endmodule
