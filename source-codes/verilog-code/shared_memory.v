`timescale 1ns / 1ps

module shared_memory #(
    parameter INIT_FILE = ""
) (
    input clk,
    // Port A (Read-only for DMA)
    input [16:0] addr_a,
    output reg [31:0] dout_a,
    // Port B (Write-only for Writeback)
    input [16:0] addr_b,
    input [31:0] din_b,
    input we_b
);
    // Memory array: 76800 words (32-bit each)
    reg [31:0] mem [0:76799];

    // Initialize memory from file (simulation only)
    initial begin
        if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
    end

    // Port A: Read (synchronous)
    always @(posedge clk) begin
        dout_a <= mem[addr_a];
    end

    // Port B: Write (synchronous)
    always @(posedge clk) begin
        if (we_b) mem[addr_b] <= din_b;
    end
endmodule
