


module controller (
    input wire [6:0] op,
    input wire [2:0] funct3,
    input wire funct7b5,
    input wire Zero, ALUR31,
    output wire [1:0] ResultSrc,
    output wire MemWrite,
    output wire PCSrc, ALUSrc,
    output wire RegWrite, Jump, Jalr,
    output wire [1:0] ImmSrc,
    output wire [3:0] ALUControl // CHANGED to 4 bits
);

wire [1:0] ALUOp;
wire Branch;

main_decoder md (op, funct3, Zero, ALUR31, ResultSrc, MemWrite, Branch,
                 ALUSrc, RegWrite, Jump, Jalr, ImmSrc, ALUOp);

alu_decoder ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// for jump and branch
assign PCSrc = Branch | Jump;

endmodule
