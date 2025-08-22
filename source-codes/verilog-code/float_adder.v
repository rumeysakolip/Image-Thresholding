`timescale 1ns / 1ps

module float_adder (
    input clk,
    input reset,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] sum,
    output reg done
);
    // Simple floating-point adder (for demonstration)
    // In real implementation, use a proper FPU or IP core
    reg [31:0] a_reg, b_reg;
    reg [7:0] exp_a, exp_b;
    reg [23:0] mantissa_a, mantissa_b; // Including implicit 1
    reg [23:0] mantissa_sum;
    reg [7:0] exp_sum;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum <= 32'b0;
            done <= 0;
        end else begin
            // Extract components
            exp_a = a[30:23];
            exp_b = b[30:23];
            mantissa_a = {1'b1, a[22:0]};
            mantissa_b = {1'b1, b[22:0]};
            
            // Align exponents
            if (exp_a > exp_b) begin
                mantissa_b = mantissa_b >> (exp_a - exp_b);
                exp_sum = exp_a;
            end else begin
                mantissa_a = mantissa_a >> (exp_b - exp_a);
                exp_sum = exp_b;
            end
            
            // Add mantissas
            mantissa_sum = mantissa_a + mantissa_b;
            
            // Normalize result
            if (mantissa_sum[23]) begin
                mantissa_sum = mantissa_sum >> 1;
                exp_sum = exp_sum + 1;
            end
            
            // Pack result
            sum <= {1'b0, exp_sum, mantissa_sum[22:0]};
            done <= 1;
        end
    end
endmodule
