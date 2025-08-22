module pixel_sum
#(
    parameter COUNT_WIDTH = 32  // Width sufficient for max image size
)
(
    input wire clk,
    input wire rst_n,
    
    // Control signals
    input wire start,        // Start counting
    input wire pixel_valid,  // Pixel data valid
    input wire in_last,      // Last pixel of image
    
    // Output
    output reg [COUNT_WIDTH-1:0] total_pixels,
    output reg done          // Counting complete
);

    // State definitions
    localparam [1:0] S_IDLE = 2'd0,
                     S_COUNT = 2'd1,
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
                if (start) next_state = S_COUNT;
            end
            S_COUNT: begin
                if (in_last && pixel_valid) next_state = S_DONE;
            end
            S_DONE: begin
                if (!start) next_state = S_IDLE;
            end
        endcase
    end
    
    // Counter logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            total_pixels <= 0;
            done <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) total_pixels <= 0;
                end
                
                S_COUNT: begin
                    if (pixel_valid) begin
                        total_pixels <= total_pixels + 1;
                    end
                end
                
                S_DONE: begin
                    done <= 1;
                end
            endcase
        end
    end

endmodule