/*
# Team ID:          < eYRC#4683 >
# Theme:            < MazeSolver Bot >
# Author List:      < Jay,Nitin,Haisam,Vishnu >
# Filename:         < pwm_generator.v >
# File Description: < To generate PWM signals and scale down frequency>
# Global variables: < None>
*/


module pwm_generator(
    input clk_3125KHz,
    input [3:0] duty_cycle,
    output reg clk_195KHz, pwm_signal
);

initial begin
    clk_195KHz = 0; pwm_signal = 1;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

/*
Add your logic here
*/

reg [3:0] counter = 0;
always @(posedge clk_3125KHz) begin
if(counter == 4'b0000 || counter == 4'b1000) clk_195KHz <= ~clk_195KHz;
if(counter < duty_cycle)
pwm_signal <= 1;
else
pwm_signal <=0;

if (counter == 4'd15)
        counter <= 0;
    else
        counter = counter + 1;
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
