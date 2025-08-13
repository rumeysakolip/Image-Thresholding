`timescale 1ns/1ps

module writeback_controller (
    input               clk,
    input               reset,
    input               start,
    output reg          done,
    //
    input       [31:0]  base_addr,
    input       [31:0]  image_size,
    //
    input       [7:0]   packed_data,
    input               data_valid,
    output reg  [31:0]  mem_addr,
    output reg  [7:0]   mem_data_out,
    output reg          mem_rw,
    output reg          mem_en
    
);
    reg [31:0] bytes_written;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_addr <= base_addr;
            bytes_written <= 0;
            done <= 1'b0;
            mem_rw <= 1'b0;
            mem_en <= 1'b0;
        end else if (start) begin
            if (bytes_written < image_size) begin
                if (data_valid) begin
                    mem_addr <= base_addr + bytes_written;
                    mem_data_out <= packed_data;
                    mem_rw <= 1'b1;
                    mem_en <= 1'b1;
                    bytes_written <= bytes_written + 1;
                end
            end else begin
                done <= 1'b1;
                mem_en <= 1'b0;
            end
        end
    end
endmodule
