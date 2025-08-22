module hist_calc_top
#(
    parameter integer COUNT_WIDTH = 24
)
(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        start,
    output wire [15:0] busy,
    output wire [15:0] done,

    input  wire        pixel_valid,
    input  wire [7:0]  pixel_in,
    input  wire        in_last,
    output wire [15:0] ready,

    // okuma portları (her modül için ayrı)
    input  wire [3:0]  rd_sel,   // hangi modülü okuyacağız (0..15)
    input  wire [3:0]  rd_addr,  // seçilen modülün adresi (0..15)
    output wire [COUNT_WIDTH-1:0] rd_data
);

    wire [COUNT_WIDTH-1:0] rd_data_array [0:15];

    genvar i;
    generate
        for (i=0; i<16; i=i+1) begin : HIST
            hist_calc #(
                .BINS(16),
                .COUNT_WIDTH(COUNT_WIDTH),
                .BASE_ADDR(i*16)
            ) u_hist (
                .clk(clk),
                .rst_n(rst_n),
                .start(start),
                .busy(busy[i]),
                .done(done[i]),
                .pixel_valid(pixel_valid),
                .pixel_in(pixel_in),
                .in_last(in_last),
                .ready(ready[i]),
                .rd_addr(rd_addr),
                .rd_data(rd_data_array[i])
            );
        end
    endgenerate

    assign rd_data = rd_data_array[rd_sel];

endmodule
