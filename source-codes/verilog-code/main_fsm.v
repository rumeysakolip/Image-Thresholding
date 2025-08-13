`timescale 1ns/1ps

module main_fsm (
    input               clk,
    input               reset,
    //
    input               dma_done,
    input       [3:0]   pe_done,
    input               pack_done,
    input               wb_done,
    //
    output reg          dma_start,
    output reg  [3:0]   pe_start,
    output reg          pack_start,
    output reg          wb_start,
    output reg          processing_done
);
    reg [3:0] state;
    
    localparam [3:0]
        IDLE        = 4'd0,
        DMA_READ    = 4'd1,
        PROCESS     = 4'd2,
        PACK        = 4'd3,
        WRITEBACK   = 4'd4,
        DONE        = 4'd5;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            dma_start <= 1'b0;
            pe_start <= 4'b0000;
            pack_start <= 1'b0;
            wb_start <= 1'b0;
            processing_done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    state <= DMA_READ;
                    dma_start <= 1'b1;
                end
                
                DMA_READ: begin
                    if (dma_done) begin
                        state <= PROCESS;
                        pe_start <= 4'b1111;
                        dma_start <= 1'b0;
                    end
                end
                
                PROCESS: begin
                    if (&pe_done) begin
                        state <= PACK;
                        pe_start <= 4'b0000;
                        pack_start <= 1'b1;
                    end
                end
                
                PACK: begin
                    if (pack_done) begin
                        state <= WRITEBACK;
                        pack_start <= 1'b0;
                        wb_start <= 1'b1;
                    end
                end
                
                WRITEBACK: begin
                    if (wb_done) begin
                        state <= DONE;
                        wb_start <= 1'b0;
                    end
                end
                
                DONE: begin
                    processing_done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
