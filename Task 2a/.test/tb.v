`timescale 1ns/1ps

module tb;
    // Dut singals
    reg clk_50M;
    reg reset;
    wire sensor;
    wire [7:0] T_integral;
    wire [7:0] T_decimal;
    wire [7:0] Checksum;
    wire [7:0] RH_integral;
    wire [7:0] RH_decimal;
    wire data_valid;

    // Expected values
    reg [7:0] exp_T_integral;
    reg [7:0] exp_T_decimal;
    reg [7:0] exp_RH_integral;
    reg [7:0] exp_RH_decimal;
    reg [7:0] exp_Checksum;
    reg exp_data_valid;

    // internal signals
    integer error_count;
    integer fw;
    integer j;

    // simulate bidirectional signal
    reg sensor_driver;
    reg sensor_drive_enable;  // 1 - output, 0 - input
    assign sensor = sensor_drive_enable ? sensor_driver : 1'bz;

    // Instantiate the DUT
    t2a_dht uut(
        .clk_50M(clk_50M),
        .reset(reset),
        .sensor(sensor),
        .T_integral(T_integral),
	    .T_decimal(T_decimal),
        .RH_integral(RH_integral),
	    .RH_decimal(RH_decimal),
	    .Checksum(Checksum),
        .data_valid(data_valid)
    );

    // Clock generation: 50MHz
    always #10 clk_50M = ~clk_50M;

    // Task to simulate one bit
    task send_bit(input reg bit_value);
        begin
            // 50us LOW
            sensor_drive_enable = 1;
            sensor_driver = 0;
            repeat(2500) @(posedge clk_50M);
            // HIGH duration determines bit
            sensor_driver = 1;
            if (bit_value)
                repeat(3500) @(posedge clk_50M); // ~70us
            else
                repeat(1300) @(posedge clk_50M); // ~26us
        end
    endtask

    task send_byte(input [7:0] data);
        integer i;
        begin
            for (i = 7; i >= 0; i = i - 1) begin
                send_bit(data[i]);      // sending bit by bit
            end
        end
    endtask

    // Initialization
    initial begin
        exp_RH_integral = 0;
        exp_RH_decimal = 0;
        exp_T_integral = 0;
        exp_T_decimal = 0;
        exp_Checksum = 0;
        exp_data_valid = 1'b0;

        clk_50M = 0;
        reset = 0;
        sensor_driver = 1;
        sensor_drive_enable = 0;
        error_count = 0;
        fw = 0; j = 0;
    end

    initial begin
        repeat(5) @(posedge clk_50M);
        reset = 1; j = 0;
        repeat(5) @(posedge clk_50M);
        // Master pulls down sensor for 18ms
        sensor_drive_enable = 1;
        sensor_driver = 0;
        repeat(900000) @(posedge clk_50M);
        // Master pulls up for 40us
        sensor_driver = 1;
        repeat(2000) @(posedge clk_50M);
        // Release line: sensor will respond
        sensor_drive_enable = 0;
        // Sensor pulls down for 80us
        sensor_drive_enable = 1;
        sensor_driver = 0;
        repeat(4000) @(posedge clk_50M);
        // Sensor pulls up for 80us
        sensor_driver = 1;
        repeat(4000) @(posedge clk_50M);
        // Send 5 bytes: RH, RH dec, Temp, Temp dec, Checksum
        send_byte(8'd55); // RH integer
        j = j + 1;
        send_byte(8'd15);  // RH decimal
        j = j + 1;
        send_byte(8'd23); // Temp integer
        j = j + 1;
        send_byte(8'd05);  // Temp decimal
        j = j + 1;
        send_byte(8'd98); // Checksum = RH int + RH dec + Temp int + Temp dec
        j = j + 1;
        // Release line
        sensor_drive_enable = 0;
        // Wait for DUT to process
        repeat(4) @(posedge clk_50M);
        exp_RH_integral = 8'd55;
        exp_RH_decimal = 8'd15;
        exp_T_integral = 8'd23;
        exp_T_decimal = 8'd05;
        exp_Checksum = exp_RH_integral + exp_RH_decimal + exp_T_integral + exp_T_decimal;
        // data valid for 1 clock cycle
        exp_data_valid = 1'b1;
        @(posedge clk_50M);
        exp_data_valid = 1'b0;
        // some delay before next packet
        repeat(5) @(posedge clk_50M);
        // Master pulls down sensor for 18ms
        sensor_drive_enable = 1;
        sensor_driver = 0;
        repeat(900000) @(posedge clk_50M);
        // Master pulls up for 40us
        sensor_driver = 1;
        repeat(2000) @(posedge clk_50M);
        // Release line: sensor will respond
        sensor_drive_enable = 0;
        // Sensor pulls down for 80us
        sensor_drive_enable = 1;
        sensor_driver = 0;
        repeat(4000) @(posedge clk_50M);
        // Sensor pulls up for 80us
        sensor_driver = 1;
        repeat(4000) @(posedge clk_50M);
        // Send 5 bytes: RH, RH dec, Temp, Temp dec, Checksum
        send_byte(8'd30); // RH integer
        j = j + 1;
        send_byte(8'd5);  // RH decimal
        j = j + 1;
        send_byte(8'd29); // Temp integer
        j = j + 1;
        send_byte(8'd01);  // Temp decimal
        j = j + 1;
        send_byte(8'd65); // Checksum = RH int + RH dec + Temp int + Temp dec
        j = j + 1;
        // Release line
        sensor_drive_enable = 0;
        // Wait for DUT to process
        repeat(4) @(posedge clk_50M);
        exp_RH_integral = 8'd30;
        exp_RH_decimal = 8'd5;
        exp_T_integral = 8'd29;
        exp_T_decimal = 8'd01;
        exp_Checksum = exp_RH_integral + exp_RH_decimal + exp_T_integral + exp_T_decimal;
        // data valid for 1 clock cycle
        exp_data_valid = 1'b1;
        @(posedge clk_50M);
        exp_data_valid = 1'b0;
        // some delay before next packet
        repeat(5) @(posedge clk_50M);
        // Master pulls down sensor for 18ms
        sensor_drive_enable = 1;
        sensor_driver = 0;
        repeat(900000) @(posedge clk_50M);
        // Master pulls up for 40us
        sensor_driver = 1;
        repeat(2000) @(posedge clk_50M);
        // Release line: sensor will respond
        sensor_drive_enable = 0;
        // Sensor pulls down for 80us
        sensor_drive_enable = 1;
        sensor_driver = 0;
        repeat(4000) @(posedge clk_50M);
        // Sensor pulls up for 80us
        sensor_driver = 1;
        repeat(4000) @(posedge clk_50M);
        // Send 5 bytes: RH, RH dec, Temp, Temp dec, Checksum
        send_byte(8'd95); // RH integer
        j = j + 1;
        send_byte(8'd2);  // RH decimal
        j = j + 1;
        send_byte(8'd78); // Temp integer
        j = j + 1;
        send_byte(8'd30);  // Temp decimal
        j = j + 1;
        send_byte(8'd205); // Checksum = RH int + RH dec + Temp int + Temp dec
        j = j + 1;
        // Release line
        sensor_drive_enable = 0;
        // Wait for DUT to process
        repeat(4) @(posedge clk_50M);
        exp_RH_integral = 8'd95;
        exp_RH_decimal = 8'd2;
        exp_T_integral = 8'd78;
        exp_T_decimal = 8'd30;
        exp_Checksum = exp_RH_integral + exp_RH_decimal + exp_T_integral + exp_T_decimal;
        // data valid for 1 clock cycle
        exp_data_valid = 1'b1;
        @(posedge clk_50M);
        exp_data_valid = 1'b0;
        // some delay before finishing
        repeat(5) @(posedge clk_50M);
    end

    always @(posedge clk_50M) begin
        #1;
        if(RH_integral !== exp_RH_integral) error_count = error_count + 1;
        if(RH_decimal !== exp_RH_decimal) error_count = error_count + 1;
        if(T_integral !== exp_T_integral) error_count = error_count + 1;
        if(T_decimal !== exp_T_decimal) error_count = error_count + 1;
        if(Checksum !== exp_Checksum) error_count = error_count + 1;
        if(data_valid !== exp_data_valid) error_count = error_count + 1;
          
        if( j >= 14) begin
            if(error_count !== 0) begin
            fw = $fopen("result.txt", "w");
            $fdisplay(fw, "%02h","Errors");
            $display("Error(s) encountered, please check your design!");
            $fclose(fw);
        end else begin
            fw = $fopen("result.txt", "w");
            $fdisplay(fw, "%02h","No Errors");
            $display("No errors encountered, congratulations!");
            $fclose(fw);
        end
        j = 0;
        end
    end

endmodule
