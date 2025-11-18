// MazeSolver Bot: Task 2B - UART Transmitter
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.

This file is used to generate UART Tx data packet to transmit the messages based on the input data.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

/*
Module UART Transmitter

Input:  clk_3125 - 3125 KHz clock
        parity_type - even(0)/odd(1) parity type
        tx_start - signal to start the communication.
        data    - 8-bit data line to transmit

Output: tx      - UART Transmission Line
        tx_done - message transmitted flag


        Baudrate : 115200 bps
*/

// module declaration
module uart_tx(
    input clk_3125,
    input parity_type,tx_start,
    input [7:0] data,
    output reg tx, tx_done
);

initial begin
    tx = 1'b1;
    tx_done = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////
 
 /*  Add your logic here */

 
 
 
 
 
 // State definitions
localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam DATA = 2'b10;
localparam PARITY_STOP = 2'b11;

// Internal registers
reg [1:0] state = IDLE;
reg [3:0] bit_count;
reg [7:0] data_reg;
reg parity_bit;

// Baud rate counter - 27 cycles per bit (3.125MHz / 115200 ≈ 27.13)
reg [4:0] baud_counter;

// State machine
always @(posedge clk_3125) begin
    case (state)
        IDLE: begin
            tx <= 1'b1;
            tx_done <= 1'b0;
            baud_counter <= 5'd0;
            bit_count <= 4'd0;
            
            if (tx_start) begin
                state <= START;
                data_reg <= data;
					 tx <= 1'b0;
                // Calculate parity bit
                if (parity_type == 1'b0) begin // Even parity
                    parity_bit <= ^data;
                end else begin // Odd parity
                    parity_bit <= ~(^data);
                end
            end
        end
        
        START: begin
            tx <= 1'b0; // Start bit
            
            if (baud_counter == 5'd25) begin
                baud_counter <= 5'd0;
                state <= DATA;
            end else begin
                baud_counter <= baud_counter + 5'd1;
            end
        end
        
        DATA: begin
            tx <= data_reg[7-bit_count];
            
            if (baud_counter == 5'd26) begin
                baud_counter <= 5'd0;
                
                if (bit_count == 4'd7) begin
                    state <= PARITY_STOP;
                    bit_count <= 4'd0;
                end else begin
                    bit_count <= bit_count + 4'd1;
                end
            end else begin
                baud_counter <= baud_counter + 5'd1;
            end
        end
        
        PARITY_STOP: begin
            // First send parity bit
            if (bit_count == 4'd0) begin
                tx <= parity_bit;
                
                if (baud_counter == 5'd26) begin
                    baud_counter <= 5'd0;
                    bit_count <= 4'd1;
                end else begin
                    baud_counter <= baud_counter + 5'd1;
                end
            end 
            // Then send stop bit
            else begin
                tx <= 1'b1;
                
                if (baud_counter == 5'd26) begin
                    baud_counter <= 5'd0;
                    state <= IDLE;
                    tx_done <= 1'b1;
                end else begin
                    baud_counter <= baud_counter + 5'd1;
                end
            end
        end
        default:
		  tx<=0;
        
    endcase
end
 
 
 
 
 
 
 
 
 
 
 
 
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule

