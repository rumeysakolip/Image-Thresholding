`timescale 1ns/1ps

module bit_packing (
    input               clk,
    input               reset,
    input               start,
    output reg          done,
    // Pixel inputs
    input               pixel_in_0,
    input               pixel_in_1,
    input               pixel_in_2,
    input               pixel_in_3,
    // Output
    output reg  [7:0]   packed_data,
    output reg          data_valid
);
    reg [2:0] bit_counter;
    reg [7:0] byte_buffer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_counter <= 0;
            byte_buffer <= 0;
            done <= 1'b0;
            data_valid <= 1'b0;
        end else if (start) begin
            case (bit_counter)
                3'd0: byte_buffer[0] <= pixel_in_0;
                3'd1: byte_buffer[1] <= pixel_in_1;
                3'd2: byte_buffer[2] <= pixel_in_2;
                3'd3: byte_buffer[3] <= pixel_in_3;
                3'd4: byte_buffer[4] <= pixel_in_0;
                3'd5: byte_buffer[5] <= pixel_in_1;
                3'd6: byte_buffer[6] <= pixel_in_2;
                3'd7: begin
                    byte_buffer[7] <= pixel_in_3;
                    packed_data <= byte_buffer;
                    data_valid <= 1'b1;
                    done <= 1'b1;
                end
            endcase
            bit_counter <= bit_counter + 1;
        end
    end
endmodule
