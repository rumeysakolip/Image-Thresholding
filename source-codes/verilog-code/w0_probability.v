`timescale 1ns / 1ps

module w0_probability (
    input clk,
    input reset,
    input [7:0] i,
    input [31:0] n_i,
    input [7:0] threshold,
    output reg [31:0] w0,  // Floating-point result
    output reg done
);
    wire [7:0] quotient;
    wire div_ready, div_ovfl;
    reg start_div;
    reg [7:0] stored_i;
    reg [31:0] stored_n_i;
    
    // Floating-point conversion
    wire [31:0] int_result;
    wire [31:0] fp_result;
    wire add_done;
    wire [31:0] add_sum;  // Wire to connect float_adder output
    
    divider #(
        .DIVIDEND_WIDTH(16),
        .DIVISOR_WIDTH(8)
    ) u_divider (
        .clk(clk),
        .reset(reset),
        .start(start_div),
        .m({8'b0, stored_i}),
        .n(stored_n_i[7:0]),
        .quotient(quotient),
        .ready(div_ready),
        .ovfl(div_ovfl)
    );
    
    int_to_float u_int_to_float (
        .int_value(int_result),
        .float_value(fp_result)
    );
    
    float_adder u_float_adder (
        .clk(clk),
        .reset(reset),
        .a(fp_result),
        .b(w0),
        .sum(add_sum),  // Connect to wire instead of directly to w0
        .done(add_done)
    );
    
    assign int_result = {24'b0, quotient};
    
    reg [2:0] state;
    parameter IDLE = 3'b000, START_DIV = 3'b001, WAIT_DIV = 3'b010, 
              CONVERT = 3'b011, START_ADD = 3'b100, WAIT_ADD = 3'b101;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w0 <= 32'b0;  // Initialize as float 0.0
            done <= 0;
            start_div <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (i < threshold && n_i != 0) begin
                        stored_i <= i;
                        stored_n_i <= n_i;
                        state <= START_DIV;
                        done <= 0;
                    end else begin
                        done <= 1;
                    end
                end
                
                START_DIV: begin
                    start_div <= 1;
                    state <= WAIT_DIV;
                end
                
                WAIT_DIV: begin
                    start_div <= 0;
                    if (div_ready && !div_ovfl) begin
                        state <= CONVERT;
                    end else if (div_ready) begin
                        state <= IDLE;
                    end
                end
                
                CONVERT: begin
                    // Conversion is combinatorial, so we can move to next state immediately
                    state <= START_ADD;
                end
                
                START_ADD: begin
                    state <= WAIT_ADD;
                end
                
                WAIT_ADD: begin
                    if (add_done) begin
                        w0 <= add_sum;  // Assign the sum from float_adder to w0
                        done <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
