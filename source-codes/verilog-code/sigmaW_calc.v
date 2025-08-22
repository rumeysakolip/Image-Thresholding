// sigmaW_calc.v
// Verilog-2001
// Basit kombinasyonel: sigmaW_sq = omega0 * sigma0_sq + omega1 * sigma1_sq
// Parametrik bit genişlikleri.

`timescale 1ns/1ps
module sigmaW_calc #(
    parameter IW    = 16,               // input width (omega0, sigma0_sq, ...)
    parameter PRODW = IW*2,             // product width (omega * sigma)
    parameter OUTW  = PRODW + 1         // sum of two products might need +1 bit
)(
    input  wire [IW-1:0] omega0,
    input  wire [IW-1:0] sigma0_sq,
    input  wire [IW-1:0] omega1,
    input  wire [IW-1:0] sigma1_sq,
    output wire [OUTW-1:0] sigmaW_sq
);

    // ara ürünler (geniş)
    wire [PRODW-1:0] prod0 = omega0 * sigma0_sq;
    wire [PRODW-1:0] prod1 = omega1 * sigma1_sq;

    // toplam (genişleştirme ile)
    wire [OUTW-1:0] sum_wide = {1'b0, prod0} + {1'b0, prod1};

    assign sigmaW_sq = sum_wide;

endmodule
