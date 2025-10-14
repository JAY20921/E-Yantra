// This module will test the ultrasonic sensor.
`timescale 1ns/1ns

module tb();

    reg clk_50M;
    reg reset;
    reg echo;
    wire trig;
    wire obstacle;
    wire [15:0] distance_out;

    reg exp_trig;
    reg [15:0] exp_distance_out;

    integer i, fw;
    integer counter, error_count;

    t1b_ultrasonic uut(
        .clk_50M(clk_50M),
        .reset(reset),
        .echo_rx(echo),
        .trig(trig),
        .op(obstacle),
        .distance_out(distance_out)
    );
    
    initial begin
        clk_50M = 0;
        reset = 1; echo = 0;
        i = 0; fw = 0;
        counter = 0; error_count = 0;
        exp_trig = 0; exp_distance_out = 0;
    end
     
    always begin
      #10 clk_50M = ~clk_50M;             
    end

    always @(posedge clk_50M) begin
        #100; reset = 1; #920;
        exp_trig = 1;
        i = i + 1;
        #10000;
        exp_trig = 0;
        echo = 1;
        repeat(50000)@(posedge clk_50M);
        echo = 0;
        @(posedge clk_50M);
        exp_distance_out = 169;
        repeat(49999)@(posedge clk_50M);
        #10001100;
        exp_trig = 1;
        i = i + 1;
        #10000;
        exp_trig = 0;
        echo = 1;
        repeat(80000)@(posedge clk_50M);
        echo = 0;
        @(posedge clk_50M);
        exp_distance_out = 271;
        repeat(19999)@(posedge clk_50M);
        #10001100;
        exp_trig = 1;
        i = i + 1;
        #10000;
        exp_trig = 0;
        echo = 1;
        repeat(100000)@(posedge clk_50M);
        echo = 0;
        @(posedge clk_50M);
        exp_distance_out = 339;
        #10001080;
        exp_trig = 1;
        i = i + 1;
        #10000;
        exp_trig = 0;
        echo = 1;
        repeat(30000)@(posedge clk_50M);
        echo = 0;
        @(posedge clk_50M);
        exp_distance_out = 101;
        repeat(69999)@(posedge clk_50M);
        echo = 0;
        #10001100;
        exp_trig = 1;
        i = i + 1;
        #10000;
        exp_trig = 0;
        @(posedge clk_50M);
        exp_distance_out = 0;
        exp_trig = 0;
        repeat(500)@(posedge clk_50M);
        //$stop();
    end

    always@(posedge clk_50M) begin
        #1;
        if(trig !== exp_trig) error_count = error_count + 1;
        if(distance_out !== exp_distance_out) error_count = error_count + 1;

        if(i >= 4 ) begin
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
        i = 0;
        end
    end

endmodule
