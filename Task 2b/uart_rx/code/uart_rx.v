
module uart_rx(
    input clk_3125,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_parity,
    output reg rx_complete
    );

initial begin
    rx_msg = 8'b0;
    rx_parity = 1'b0;
    rx_complete = 1'b0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE//////////////////

// Internal registers


// States
localparam IDLE      = 4'd0;
localparam START_BIT = 4'd1;
localparam DATA_BITS = 4'd2;
localparam PARITY_BIT = 4'd3;
localparam STOP_BIT  = 4'd4;

//Assigning States

reg [2:0]current_state= IDLE;
reg [8:0] rx_buffer=9'b0;
// BIT_DURATION 
integer clk_counter = 0;
integer bit_count = 0;
parameter BIT_DURATION = 5'd27;



// Main state machine
always @(posedge clk_3125) begin
    case (current_state)
        IDLE: begin
                current_state <= START_BIT;
            end
        
        
        START_BIT: begin
				bit_count =0;
            rx_complete<=0;
				if(rx==0) begin
				 bit_count = 0;
				if(clk_counter < BIT_DURATION-2) begin
				clk_counter = clk_counter + 1 ;
						end 
				else begin
				clk_counter = 0 ;
				current_state <= DATA_BITS ;
						end
				end
        end
        
        DATA_BITS: begin 

			if(clk_counter == (BIT_DURATION -1)/2 ) begin
			current_state <= PARITY_BIT ;
			rx_buffer[8] <= rx;
			clk_counter=0;
			bit_count=1;
			end
			else begin
			clk_counter= clk_counter +1 ;
			end
 

		end
        
        PARITY_BIT: 
            begin
		if(bit_count<9)begin
			if(clk_counter < BIT_DURATION-1) begin
				clk_counter = clk_counter+1;
			end 
			else begin
			rx_buffer[8-bit_count]<=rx;
			bit_count=bit_count+1;
			clk_counter=0;
			end
		end
			else begin
			if(clk_counter <= (BIT_DURATION-1)/2-1)begin
			clk_counter = clk_counter +1 ;
				end
			else begin
		current_state <= STOP_BIT ;
			clk_counter = 0;
			end
		end
end
        
        
        STOP_BIT: begin
           
			if(clk_counter < BIT_DURATION-1) begin
			clk_counter = clk_counter+1;
			end
			else begin
					if(rx_buffer[0] ==^ rx_buffer[8:1]) begin
					rx_msg<= rx_buffer[8:1];
					rx_parity<=rx_buffer[0];
					rx_complete<=1'b1;
					end
					else begin
					rx_msg<= 8'h3F;
					rx_complete<=1'b1;
					rx_parity<=rx_buffer[0];
					end
					current_state<= START_BIT;
					clk_counter = 0;
		
			end
        end
        
        
    endcase
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule