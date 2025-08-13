`timescale 1ns/1ps

module dma_controller #(
    parameter IMAGE_SIZE = 4096 // 64x64 for simulation
)(
    input               clk,
    input               reset,
    input               start,
    output reg          done,
    input       [7:0]   mem_data_in,
    output reg  [31:0]  mem_addr,
    output              mem_rw,
    output              mem_en,
    // FIFO 0
    output reg  [7:0]   fifo_data_0,
    input               fifo_empty_0,
    output reg          fifo_rd_en_0,
    // FIFO 1
    output reg  [7:0]   fifo_data_1,
    input               fifo_empty_1,
    output reg          fifo_rd_en_1,
    // FIFO 2
    output reg  [7:0]   fifo_data_2,
    input               fifo_empty_2,
    output reg          fifo_rd_en_2,
    // FIFO 3
    output reg  [7:0]   fifo_data_3,
    input               fifo_empty_3,
    output reg          fifo_rd_en_3
);
    reg [31:0] addr_counter;
    
    assign mem_rw = 1'b0; // Always read
    assign mem_en = start && !done;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr_counter <= 0;
            done <= 1'b0;
            fifo_rd_en_0 <= 1'b0;
            fifo_rd_en_1 <= 1'b0;
            fifo_rd_en_2 <= 1'b0;
            fifo_rd_en_3 <= 1'b0;
        end else if (start) begin
            if (addr_counter < IMAGE_SIZE) begin
                mem_addr <= addr_counter;
                case (addr_counter[1:0])
                    2'b00: begin
                        fifo_data_0 <= mem_data_in;
                        fifo_rd_en_0 <= 1'b1;
                    end
                    2'b01: begin
                        fifo_data_1 <= mem_data_in;
                        fifo_rd_en_1 <= 1'b1;
                    end
                    2'b10: begin
                        fifo_data_2 <= mem_data_in;
                        fifo_rd_en_2 <= 1'b1;
                    end
                    2'b11: begin
                        fifo_data_3 <= mem_data_in;
                        fifo_rd_en_3 <= 1'b1;
                    end
                endcase
                addr_counter <= addr_counter + 1;
            end else begin
                done <= 1'b1;
            end
        end
    end
endmodule
