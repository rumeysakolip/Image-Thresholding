`timescale 1ns / 1ps

module int_to_float (
    input clk,
    input reset,
    input [31:0] int_value,
    input valid_in,
    output reg [31:0] float_out,
    output reg valid_out
);
    // Simplified integer to float conversion
    // In a real implementation, this would follow IEEE 754 conversion rules
    reg [31:0] input_reg;
    reg processing;
    
    localparam [31:0] msb_pos;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            float_out <= 32'd0;
            valid_out <= 1'b0;
            input_reg <= 32'd0;
            processing <= 1'b0;
        end else begin
            valid_out <= 1'b0;
            
            if (valid_in && !processing) begin
                input_reg <= int_value;
                processing <= 1'b1;
            end
            
            if (processing) begin
                // Convert integer to float (simplified)
                if (input_reg == 0) begin
                    float_out <= 32'd0;
                end else begin
                    // Find the position of the most significant bit
                    for (msb_pos = 31; msb_pos >= 0; msb_pos = msb_pos - 1) begin
                        if (input_reg[msb_pos]) break;
                    end
                    
                    // Calculate exponent (127 + msb_pos)
                    float_out[30:23] = 127 + msb_pos;
                    
                    // Calculate mantissa
                    if (msb_pos > 23) begin
                        float_out[22:0] = input_reg[msb_pos-1:msb_pos-23];
                    end else begin
                        float_out[22:23-msb_pos] = input_reg[msb_pos-1:0];
                        float_out[22-msb_pos:0] = 0;
                    end
                    
                    // Set sign bit to 0 (positive)
                    float_out[31] = 0;
                end
                
                valid_out <= 1'b1;
                processing <= 1'b0;
            end
        end
    end
endmodule
