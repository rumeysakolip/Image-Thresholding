`timescale 1ns / 1ps

module cumulative_probability (
    input clk,
    input reset,
    input [7:0] i,
    input [31:0] n_i,
    input [7:0] threshold,
    input valid_in,
    output reg [31:0] p_bg,
    output reg [31:0] p_fg,
    output reg valid_out
);

    // Internal registers
    reg [31:0] w0, w1;  // Accumulators for bg and fg
    reg [8:0] count;     // Counter for inputs (0-256)
    reg processing;      // State indicator
    
    // Floating-point conversion signals
    wire [31:0] float_i, float_n_i;
    wire conv_valid_i, conv_valid_n;
    
    // Division signals
    wire [31:0] div_result;
    wire div_valid;
    
    // Addition signals
    wire [31:0] add_result_bg, add_result_fg;
    wire add_valid_bg, add_valid_fg;
    
    // Control signals
    wire is_bg = (i < threshold);
    wire last_input = (count == 9'd255);
    
    // Instantiate converters
    int_to_float conv_i (
        .clk(clk),
        .reset(reset),
        .int_value({24'd0, i}),
        .valid_in(valid_in),
        .float_out(float_i),
        .valid_out(conv_valid_i)
    );
    
    int_to_float conv_n (
        .clk(clk),
        .reset(reset),
        .int_value(n_i),
        .valid_in(valid_in),
        .float_out(float_n_i),
        .valid_out(conv_valid_n)
    );
    
    // Instantiate divider
    divider fp_divider (
        .clk(clk),
        .reset(reset),
        .a(float_i),
        .b(float_n_i),
        .valid_in(conv_valid_i & conv_valid_n),
        .result(div_result),
        .valid_out(div_valid)
    );
    
    // Instantiate adders
    float_adder adder_bg (
        .clk(clk),
        .reset(reset),
        .a(w0),
        .b(div_result),
        .valid_in(div_valid & is_bg),
        .result(add_result_bg),
        .valid_out(add_valid_bg)
    );
    
    float_adder adder_fg (
        .clk(clk),
        .reset(reset),
        .a(w1),
        .b(div_result),
        .valid_in(div_valid & ~is_bg),
        .result(add_result_fg),
        .valid_out(add_valid_fg)
    );
    
    // Control logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w0 <= 32'd0;
            w1 <= 32'd0;
            count <= 9'd0;
            p_bg <= 32'd0;
            p_fg <= 32'd0;
            valid_out <= 1'b0;
            processing <= 1'b0;
        end else begin
            valid_out <= 1'b0;
            
            if (valid_in) begin
                count <= count + 1;
                processing <= 1'b1;
            end
            
            if (add_valid_bg) begin
                w0 <= add_result_bg;
            end
            
            if (add_valid_fg) begin
                w1 <= add_result_fg;
            end
            
            if (last_input && processing) begin
                p_bg <= w0;
                p_fg <= w1;
                valid_out <= 1'b1;
                count <= 9'd0;
                processing <= 1'b0;
            end
        end
    end

endmodule
