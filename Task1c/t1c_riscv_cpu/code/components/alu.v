module alu #(parameter WIDTH = 32) (
    input wire [WIDTH-1:0] a, b,        // operands
    input wire [3:0] alu_ctrl,            // ALU control (CHANGED to 4 bits)
    output reg [WIDTH-1:0] alu_out,     // ALU output
    output wire zero                      // zero flag
);

// New 4-bit ALU Control Codes
localparam ADD  = 4'b0000;
localparam SUB  = 4'b0001;
localparam AND  = 4'b0010;
localparam OR   = 4'b0011;
localparam XOR  = 4'b0100;
localparam SLT  = 4'b0101;
localparam SLTU = 4'b0110;
localparam SLL  = 4'b0111;
localparam SRL  = 4'b1000; // NEW
localparam SRA  = 4'b1001; // NEW

always @(*) begin
    case (alu_ctrl)
        ADD:  alu_out = a + b;
        SUB:  alu_out = a - b;
        AND:  alu_out = a & b;
        OR:   alu_out = a | b;
        XOR:  alu_out = a ^ b;
        SLT:  alu_out = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
        SLTU: alu_out = (a < b) ? 32'd1 : 32'd0;
        SLL:  alu_out = a << b[4:0];
        SRL:  alu_out = a >> b[4:0];                    // FIXED
        SRA:  alu_out = $signed(a) >>> b[4:0];        // FIXED
        default: alu_out = 32'b0;
    endcase
end

assign zero = (alu_out == 32'b0);

endmodule