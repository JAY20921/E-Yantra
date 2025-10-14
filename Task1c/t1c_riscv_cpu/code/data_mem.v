// data_mem.v - data memory with byte/half/word read-write support
module data_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MEM_SIZE   = 64
) (
    input                   clk,
    input                   wr_en,
    input       [2:0]       funct3,     // for lb, lh, lw, lbu, lhu, sb, sh, sw
    input       [ADDR_WIDTH-1:0] wr_addr,
    input       [DATA_WIDTH-1:0] wr_data,
    output reg  [DATA_WIDTH-1:0] rd_data_mem
);

    // 64 x 32-bit words = 256 bytes
    reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];
    wire [5:0] word_addr = wr_addr[ADDR_WIDTH-1:2]; // drop 2 LSB bits (word addressing)

    // -----------------------------
    // Synchronous write
    // -----------------------------
    always @(posedge clk) begin
        if (wr_en) begin
            case (funct3)
                3'b000: begin // SB (store byte)
                    case (wr_addr[1:0])
                        2'b00: data_ram[word_addr][7:0]   <= wr_data[7:0];
                        2'b01: data_ram[word_addr][15:8]  <= wr_data[7:0];
                        2'b10: data_ram[word_addr][23:16] <= wr_data[7:0];
                        2'b11: data_ram[word_addr][31:24] <= wr_data[7:0];
                    endcase
                end
                3'b001: begin // SH (store half)
                    if (wr_addr[1] == 1'b0)
                        data_ram[word_addr][15:0] <= wr_data[15:0];
                    else
                        data_ram[word_addr][31:16] <= wr_data[15:0];
                end
                3'b010: data_ram[word_addr] <= wr_data; // SW (store word)
                default: ; // no write
            endcase
        end
    end

    // -----------------------------
    // Combinational read
    // -----------------------------
    always @(*) begin
        case (funct3)
            3'b000: begin // LB (signed byte)
                case (wr_addr[1:0])
                    2'b00: rd_data_mem = {{24{data_ram[word_addr][7]}},  data_ram[word_addr][7:0]};
                    2'b01: rd_data_mem = {{24{data_ram[word_addr][15]}}, data_ram[word_addr][15:8]};
                    2'b10: rd_data_mem = {{24{data_ram[word_addr][23]}}, data_ram[word_addr][23:16]};
                    2'b11: rd_data_mem = {{24{data_ram[word_addr][31]}}, data_ram[word_addr][31:24]};
                endcase
            end

            3'b001: begin // LH (signed half)
                if (wr_addr[1] == 1'b0)
                    rd_data_mem = {{16{data_ram[word_addr][15]}}, data_ram[word_addr][15:0]};
                else
                    rd_data_mem = {{16{data_ram[word_addr][31]}}, data_ram[word_addr][31:16]};
            end

            3'b010: rd_data_mem = data_ram[word_addr]; // LW (word)

            3'b100: begin // LBU (unsigned byte)
                case (wr_addr[1:0])
                    2'b00: rd_data_mem = {24'b0, data_ram[word_addr][7:0]};
                    2'b01: rd_data_mem = {24'b0, data_ram[word_addr][15:8]};
                    2'b10: rd_data_mem = {24'b0, data_ram[word_addr][23:16]};
                    2'b11: rd_data_mem = {24'b0, data_ram[word_addr][31:24]};
                endcase
            end

            3'b101: begin // LHU (unsigned half)
                if (wr_addr[1] == 1'b0)
                    rd_data_mem = {16'b0, data_ram[word_addr][15:0]};
                else
                    rd_data_mem = {16'b0, data_ram[word_addr][31:16]};
            end

            default: rd_data_mem = 32'b0; // avoids latch inference
        endcase
    end

endmodule
