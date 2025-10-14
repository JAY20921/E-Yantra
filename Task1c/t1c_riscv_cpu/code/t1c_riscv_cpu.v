
// t1c_riscv_cpu.v - Top Module to test riscv_cpu
/*
# Team ID:          4683
# Theme:            Mazesolver
# Author List:      Jay Lade, Nitin Dhankar, Mohd Haisam Khan, Gottipati Vishnu Vardhan Babu
# Filename:         slti_implementation.v
# File Description: Implementation of SLTI instruction support in RISC-V CPU (controller, ALU, and immediate logic)
# Global variables: None
*/


module t1c_riscv_cpu (
    input         clk, reset,
    input         Ext_MemWrite,
    input  [31:0] Ext_WriteData, Ext_DataAdr,
    output        MemWrite,
    output [31:0] WriteData, DataAdr, ReadData,
    output [31:0] PC, Result
);

wire [31:0] Instr;
wire [31:0] DataAdr_rv32, WriteData_rv32;
wire        MemWrite_rv32;

// instantiate processor and memories
riscv_cpu rvcpu    (clk, reset, PC, Instr,
                    MemWrite_rv32, DataAdr_rv32,
                    WriteData_rv32, ReadData, Result);
instr_mem instrmem (PC, Instr);
data_mem  datamem  (clk, MemWrite, Instr[14:12], DataAdr, WriteData, ReadData);

assign MemWrite  = (Ext_MemWrite && reset) ? 1 : MemWrite_rv32;
assign WriteData = (Ext_MemWrite && reset) ? Ext_WriteData : WriteData_rv32;
assign DataAdr   = reset ? Ext_DataAdr : DataAdr_rv32;

endmodule

