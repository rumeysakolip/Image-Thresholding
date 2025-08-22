module prefix_accumulator
#(
    parameter COUNT_WIDTH = 32,         // Width of count values
    parameter INTENSITY_WIDTH = 32      // Width of intensity sum values
)
(
    input wire clk,
    input wire rst_n,
    
    // Control signals
    input wire start,                   // Start calculation
    output reg done,                    // Calculation complete
    
    // Input data
    input wire [COUNT_WIDTH-1:0] total_pixels,
    input wire [INTENSITY_WIDTH-1:0] total_intensity_sum,
    
    // Cumulative sum inputs
    input wire [COUNT_WIDTH-1:0] cumulative_count,    // w1 (cumulative pixel count)
    input wire [INTENSITY_WIDTH-1:0] cumulative_sum,  // m1 (cumulative intensity sum)
    input wire input_valid,             // Input data valid
    input wire input_last,              // Last input data
    
    // Outputs
    output reg [COUNT_WIDTH-1:0] w1,    // Cumulative pixel count (background)
    output reg [INTENSITY_WIDTH-1:0] m1, // Cumulative intensity (background)
    output reg [COUNT_WIDTH-1:0] w2,    // Remaining pixel count (foreground)
    output reg [INTENSITY_WIDTH-1:0] m2, // Remaining intensity (foreground)
    output reg output_valid,            // Output data valid
    output reg output_last              // Last output data
);

    // State definitions
    localparam [1:0] S_IDLE = 2'd0,
                     S_CALC = 2'd1,
                     S_DONE = 2'd2;
    
    reg [1:0] state, next_state;
    
    // FSM state transition
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // FSM next state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (start) next_state = S_CALC;
            end
            S_CALC: begin
                if (input_last && input_valid) next_state = S_DONE;
            end
            S_DONE: begin
                next_state = S_IDLE;
            end
        endcase
    end
    
    // Calculation logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w1 <= 0;
            m1 <= 0;
            w2 <= 0;
            m2 <= 0;
            output_valid <= 0;
            output_last <= 0;
            done <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    output_valid <= 0;
                    output_last <= 0;
                    if (start) begin
                        // Initialize outputs
                        w1 <= 0;
                        m1 <= 0;
                        w2 <= total_pixels;
                        m2 <= total_intensity_sum;
                    end
                end
                
                S_CALC: begin
                    if (input_valid) begin
                        // Calculate outputs
                        w1 <= cumulative_count;
                        m1 <= cumulative_sum;
                        w2 <= total_pixels - cumulative_count;
                        m2 <= total_intensity_sum - cumulative_sum;
                        output_valid <= 1;
                        output_last <= input_last;
                    end else begin
                        output_valid <= 0;
                        output_last <= 0;
                    end
                end
                
                S_DONE: begin
                    done <= 1;
                    output_valid <= 0;
                    output_last <= 0;
                end
            endcase
        end
    end

endmodule