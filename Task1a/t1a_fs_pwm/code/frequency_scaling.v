/*
# Team ID:          < eYRC#4683 >
# Theme:            < MazeSolver Bot >
# Author List:      < Jay,Nitin,Haisam,Vishnu >
# Filename:         < frequency_scaling.v >
# File Description: < Scaling frequency>
# Global variables: < None>
*/

module frequency_scaling (
    input clk_50M,
    output reg clk_3125KHz
);

initial begin
    clk_3125KHz = 0;
end
//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

/*
Add your logic here
*/

reg [2:0] counter = 0;
always @ (posedge clk_50M) begin
    if (!counter) clk_3125KHz = ~clk_3125KHz; 
    counter = counter + 1'b1; 
end

//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE //////////////////

endmodule
