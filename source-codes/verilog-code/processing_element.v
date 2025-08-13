`timescale 1ns/1ps

module processing_element (
    input               clk,
    input               reset,
    input               start,
    output reg          done,
    input       [7:0]   pixel_in,
    input               fifo_empty,
    output reg          fifo_rd_en,
    output reg  [7:0]   threshold,
    output reg          pixel_out
);
    reg [7:0] hist [0:255];
    reg [15:0] var_max, var_current;
    reg [7:0] t, best_t;
    reg [31:0] sum, sumB, sumF;
    reg [15:0] wB, wF;
    reg [15:0] count;
    
    localparam BLOCK_SIZE = 1024; // 64x64/4
    
    // Initialize histogram
    integer i;
    initial begin
        for (i=0; i<256; i=i+1) hist[i] = 0;
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 1'b0;
            threshold <= 8'd128;
            fifo_rd_en <= 1'b0;
            count <= 0;
            var_max <= 0;
        end else if (start) begin
            if (!done) begin
                // Histogram collection
                if (!fifo_empty && count < BLOCK_SIZE) begin
                    hist[pixel_in] <= hist[pixel_in] + 1;
                    fifo_rd_en <= 1'b1;
                    count <= count + 1;
                end else if (count == BLOCK_SIZE) begin
                    // Otsu's threshold calculation
                    if (t < 255) begin
                        // Variance calculations (simplified)
                        wB = (sumB << 8) / BLOCK_SIZE;
                        wF = (sumF << 8) / BLOCK_SIZE;
                        var_current = (wB * wF) >> 8;
                        
                        if (var_current > var_max) begin
                            var_max <= var_current;
                            best_t <= t;
                        end
                        t <= t + 1;
                    end else begin
                        threshold <= best_t;
                        done <= 1'b1;
                    end
                end
            end
            
            // Binary output
            if (done) begin
                pixel_out <= (pixel_in >= threshold);
                fifo_rd_en <= !fifo_empty;
            end
        end
    end
endmodule
