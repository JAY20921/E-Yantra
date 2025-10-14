module alu_decoder (
    input wire opb5,
    input wire [2:0] funct3,
    input wire funct7b5,
    input wire [1:0] ALUOp,
    output reg [3:0] ALUControl // CHANGED to 4 bits
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
localparam SRL  = 4'b1000;
localparam SRA  = 4'b1001;

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = ADD;
        2'b01: ALUControl = SUB;
        default:
            case (funct3)
                3'b000: ALUControl = (funct7b5 & opb5) ? SUB : ADD;
                3'b001: ALUControl = SLL;
                3'b010: ALUControl = SLT;
                3'b011: ALUControl = SLTU;
                3'b100: ALUControl = XOR;
                3'b101: ALUControl = (funct7b5) ? SRA : SRL; // FIXED LOGIC
                3'b110: ALUControl = OR;
                3'b111: ALUControl = AND;
                default: ALUControl = 4'bxxxx;
            endcase
    endcase
end
endmodule