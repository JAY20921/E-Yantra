
/*
# Team ID:          4683
# Theme:            Mazesolver
# Author List:      Jay Lade, Nitin Dhankar, Mohd Haisam Khan, Gottipati Vishnu Vardhan Babu
# Filename:         t2a_dht.v
# File Description: Verilog module for interfacing with a DHT sensor to acquire temperature and humidity data using a state machine, with outputs for integral and decimal values and checksum validation.

*/


module t2a_dht(
    input clk_50M,
    input reset,
    inout sensor,
    output reg [7:0] T_integral,
    output reg [7:0] RH_integral,
    output reg [7:0] T_decimal,
    output reg [7:0] RH_decimal,
    output reg [7:0] Checksum,
    output reg data_valid
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

// Internal signals
reg sensor_drive_dir;
reg sensor_drive_val;
reg [5:0] bit_index;

assign sensor = (sensor_drive_dir) ? sensor_drive_val : 1'bz;
wire sensor_read = sensor;

// FSM states 
parameter 
    ST_RESP_LOW    = 4'b0010,
    ST_RESP_HIGH   = 4'b0011,
    ST_BIT_LOW     = 4'b0100,
    ST_BIT_HIGH    = 4'b0101,
    ST_CHECKSUM    = 4'b0110,
    ST_START_LOW   = 4'b0000,
    ST_START_HIGH  = 4'b0001,
    ST_OUTPUT      = 4'b0111;

// Timing thresholds 
parameter TH_START_LOW    = 899990;
parameter TH_START_HIGH   = 1990;
parameter TH_RESP_LOW     = 3990;
parameter TH_RESP_HIGH    = 3990;
parameter TH_BIT_LOW      = 2490;
parameter TH_BIT_HIGH_1   = 2390;
parameter TH_BIT_HIGH_0   = 1290;

reg [31:0] time_cnt;
reg valid_buf;
reg [3:0]  fsm_state;
reg [39:0] data_bits;

// Synchronous reset and FSM logic
always @(posedge clk_50M) begin
    if (!reset) begin
        fsm_state   <= ST_START_LOW;
        sensor_drive_val <= 1'b0;
        sensor_drive_dir <= 1'b0;
        bit_index   <= 0;
        time_cnt    <= 0;
        data_bits   <= 0;
        valid_buf   <= 0;
        T_integral  <= 0;
        RH_integral <= 0;
        T_decimal   <= 0;
        RH_decimal  <= 0;
        Checksum    <= 0;
        data_valid  <= 0;   
    end
    else begin
        case (fsm_state)

        ST_START_LOW: begin
            sensor_drive_dir <= 1'b1;
            sensor_drive_val <= 1'b0;
            time_cnt <= time_cnt + 1;
            valid_buf <= 0;
            if (time_cnt >= TH_START_LOW) begin
                fsm_state <= ST_START_HIGH;
                sensor_drive_val <= 1'b1;
                time_cnt <= 0;
            end
        end

        ST_START_HIGH: begin
            time_cnt <= time_cnt + 1;
            if (time_cnt >= TH_START_HIGH) begin
                fsm_state <= ST_RESP_LOW;
                sensor_drive_dir <= 1'b0;
                time_cnt <= 0;
            end
        end

        ST_RESP_LOW: begin
            if (sensor_read == 0) begin
                time_cnt <= time_cnt + 1;
                if (time_cnt >= TH_RESP_LOW) begin
                    fsm_state <= ST_RESP_HIGH;
                    time_cnt <= 0;
                end
            end
        end

        ST_RESP_HIGH: begin
            if (sensor_read == 1) begin
                time_cnt <= time_cnt + 1;
                if (time_cnt >= TH_RESP_HIGH) begin
                    fsm_state <= ST_BIT_LOW;
                    bit_index <= 0;
                    time_cnt <= 0;
                end
            end
        end

        ST_BIT_LOW: begin
            if (bit_index >= 40) begin
                fsm_state <= ST_CHECKSUM;
                time_cnt <= 0;
            end
            else if (sensor_read == 0) begin
                time_cnt <= time_cnt + 1;
                if (time_cnt >= TH_BIT_LOW) begin
                    fsm_state <= ST_BIT_HIGH;
                    time_cnt <= 0;
                end
            end
        end

        ST_BIT_HIGH: begin
            if (sensor_read == 1) begin
                time_cnt <= time_cnt + 1;
            end
            else begin
                if (bit_index <= 40) begin
                    if (time_cnt >= TH_BIT_HIGH_1) begin
                        data_bits[39 - bit_index] <= 1'b1;
                        bit_index <= bit_index + 1;
                        fsm_state <= ST_BIT_LOW;
                        time_cnt <= 0;
                    end
                    else if (time_cnt >= TH_BIT_HIGH_0 && time_cnt <= TH_BIT_HIGH_1) begin
                        data_bits[39 - bit_index] <= 1'b0;
                        bit_index <= bit_index + 1;
                        fsm_state <= ST_BIT_LOW;
                        time_cnt <= 0;
                    end
                end
            end
        end

        ST_CHECKSUM: begin
            if (data_bits[7:0] == (data_bits[15:8] + data_bits[23:16] + data_bits[31:24] + data_bits[39:32])) begin
                valid_buf <= 1'b1;
            end
            else begin
                valid_buf <= 1'b0;
            end
            fsm_state <= ST_OUTPUT;
        end

        ST_OUTPUT: begin
            T_integral  <= data_bits[23:16];
            RH_integral <= data_bits[39:32];
            T_decimal   <= data_bits[15:8];
            RH_decimal  <= data_bits[31:24];
            Checksum    <= data_bits[7:0];
            valid_buf   <= 0;
            fsm_state   <= ST_START_LOW;
        end

        default: begin
            fsm_state <= ST_START_LOW;
            T_integral <= 0;
            RH_integral <= 0;
            T_decimal <= 0;
            RH_decimal <= 0;
            Checksum <= 0;
            valid_buf <= 0;
            data_valid <= 0;
        end

        endcase

        data_valid <= valid_buf;
    end
end

////////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
