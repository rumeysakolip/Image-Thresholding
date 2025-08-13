`timescale 1ns/1ps

module otsu_top # (
    // Parameters
    parameter IMAGE_WIDTH = 64,
    parameter IMAGE_HEIGHT = 64
)(
    input clk,
    input reset,
    // Memory Interface
    input [7:0] mem_data_in,
    output [31:0] mem_addr,
    output mem_rw,
    output mem_en,
    output [7:0] mem_data_out,
    output processing_done,
    // Debug/observation outputs
    output [3:0] fifo_rd_en_obs,  // test
    output [7:0] threshold_obs,   // test
    output [3:0] pixel_out_obs    // test
);

    // Parameters
    localparam TOTAL_PIXELS = IMAGE_WIDTH * IMAGE_HEIGHT;
    
    // Control Signals
    wire dma_start, dma_done;
    wire [3:0] pe_start, pe_done;
    wire pack_start, pack_done;
    wire wb_start, wb_done;
    
    // FIFO Interfaces (internal wires)
    wire [7:0] fifo_data_0, fifo_data_1, fifo_data_2, fifo_data_3;
    wire fifo_empty_0, fifo_empty_1, fifo_empty_2, fifo_empty_3;
    wire [3:0] fifo_rd_en;  // Internal wire for PE FIFO read enables
    
    // Threshold Values (internal wires)
    wire [7:0] threshold_0, threshold_1, threshold_2, threshold_3;
    
    // Pixel Outputs (internal wires)
    wire pixel_out_0, pixel_out_1, pixel_out_2, pixel_out_3;
    
    // Bit-Packing
    wire [7:0] packed_data;
    wire pack_data_valid;
    
    // Writeback
    wire [31:0] wb_mem_addr;
    wire wb_mem_rw, wb_mem_en;

    // Assign observation outputs
    assign fifo_rd_en_obs = fifo_rd_en;
    assign threshold_obs = threshold_0;  // Observing PE0's threshold
    assign pixel_out_obs = {pixel_out_3, pixel_out_2, pixel_out_1, pixel_out_0};

    // Module Instantiations
    dma_controller dma (
        .clk(clk), .reset(reset),
        .start(dma_start), .done(dma_done),
        .mem_data_in(mem_data_in),
        .mem_addr(dma_mem_addr), .mem_rw(dma_mem_rw), .mem_en(dma_mem_en),
        .fifo_data_0(fifo_data_0), .fifo_empty_0(fifo_empty_0), .fifo_rd_en_0(fifo_rd_en[0]),
        .fifo_data_1(fifo_data_1), .fifo_empty_1(fifo_empty_1), .fifo_rd_en_1(fifo_rd_en[1]),
        .fifo_data_2(fifo_data_2), .fifo_empty_2(fifo_empty_2), .fifo_rd_en_2(fifo_rd_en[2]),
        .fifo_data_3(fifo_data_3), .fifo_empty_3(fifo_empty_3), .fifo_rd_en_3(fifo_rd_en[3])
    );

    // Processing Element 0
    processing_element pe0 (
        .clk(clk), .reset(reset),
        .start(pe_start[0]), .done(pe_done[0]),
        .pixel_in(fifo_data_0),
        .fifo_empty(fifo_empty_0),
        .fifo_rd_en(fifo_rd_en[0]),
        .threshold(threshold_0),
        .pixel_out(pixel_out_0)
    );
    
    // Processing Element 1
    processing_element pe1 (
        .clk(clk), .reset(reset),
        .start(pe_start[1]), .done(pe_done[1]),
        .pixel_in(fifo_data_1),
        .fifo_empty(fifo_empty_1),
        .fifo_rd_en(fifo_rd_en[1]),
        .threshold(threshold_1),
        .pixel_out(pixel_out_1)
    );
    
    // Processing Element 2
    processing_element pe2 (
        .clk(clk), .reset(reset),
        .start(pe_start[2]), .done(pe_done[2]),
        .pixel_in(fifo_data_2),
        .fifo_empty(fifo_empty_2),
        .fifo_rd_en(fifo_rd_en[2]),
        .threshold(threshold_2),
        .pixel_out(pixel_out_2)
    );
    
    // Processing Element 3
    processing_element pe3 (
        .clk(clk), .reset(reset),
        .start(pe_start[3]), .done(pe_done[3]),
        .pixel_in(fifo_data_3),
        .fifo_empty(fifo_empty_3),
        .fifo_rd_en(fifo_rd_en[3]),
        .threshold(threshold_3),
        .pixel_out(pixel_out_3)
    );

    bit_packing packer (
        .clk(clk), .reset(reset),
        .start(pack_start), .done(pack_done),
        .threshold_0(threshold_0), .threshold_1(threshold_1),
        .threshold_2(threshold_2), .threshold_3(threshold_3),
        .pixel_in_0(pixel_out_0), .pixel_in_1(pixel_out_1),
        .pixel_in_2(pixel_out_2), .pixel_in_3(pixel_out_3),
        .packed_data(packed_data), .data_valid(pack_data_valid)
    );

    writeback_controller wb (
        .clk(clk), .reset(reset),
        .start(wb_start), .done(wb_done),
        .base_addr(32'h0010_0000), .image_size(TOTAL_PIXELS/8),
        .packed_data(packed_data), .data_valid(pack_data_valid),
        .mem_addr(wb_mem_addr), .mem_data_out(mem_data_out),
        .mem_rw(wb_mem_rw), .mem_en(wb_mem_en)
        
    );

    main_fsm controller (
        .clk(clk), .reset(reset),
        .dma_done(dma_done), .pe_done(pe_done),
        .pack_done(pack_done), .wb_done(wb_done),
        .dma_start(dma_start), .pe_start(pe_start),
        .pack_start(pack_start), .wb_start(wb_start),
        .processing_done(processing_done)
    );

    // Memory Interface Muxing
    assign mem_addr = wb_mem_en ? wb_mem_addr : dma_mem_addr;
    assign mem_rw = wb_mem_en ? wb_mem_rw : 1'b0;
    assign mem_en = wb_mem_en ? wb_mem_en : dma_mem_en;
    
endmodule
