`timescale 1ns / 1ps
// combinational squarer: out = in * in

module sq #(
    parameter EXP = 4,
    parameter MANT = 8,
    parameter OUTW = 2*(EXP+MANT)
)(
    input  wire [EXP+MANT:0] a, // 13
    output wire [OUTW:0] y      // 25
);
    wire [2*EXP-1:0] x;
    wire [2*EXP-1:0] z;
    
    assign x = a[EXP+MANT-1:MANT] * a[EXP+MANT-1:MANT];
    assign z = a[MANT-1:0] * a[MANT-1:0];
    assign y = {x,z};
endmodule
