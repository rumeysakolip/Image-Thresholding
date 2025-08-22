module hist_calc
#(
    parameter integer BINS = 16,
    parameter integer COUNT_WIDTH = 24,
    parameter integer BASE_ADDR = 0   // bu modülün kapsadığı aralık (örn: 0, 16, 32 …)
)
(
    input  wire                   clk,
    input  wire                   rst_n,

    // kontrol
    input  wire                   start,
    output reg                    busy,
    output reg                    done,

    // piksel girişi
    input  wire                   pixel_valid,
    input  wire [7:0]             pixel_in,
    input  wire                   in_last,
    output reg                    ready,

    // histogram okuma
    input  wire [$clog2(BINS)-1:0] rd_addr,
    output reg [COUNT_WIDTH-1:0]   rd_data
);

    reg [COUNT_WIDTH-1:0] hist [0:BINS-1];

    localparam [1:0] S_IDLE  = 2'd0,
                     S_CLEAR = 2'd1,
                     S_RUN   = 2'd2,
                     S_DONE  = 2'd3;
    reg [1:0] state;

    reg [$clog2(BINS):0] clr_idx;
    reg [COUNT_WIDTH-1:0] temp_count;
    integer i;

    // okuma
    always @(posedge clk) begin
        rd_data <= hist[rd_addr];
    end

    // FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            busy  <= 0;
            done  <= 0;
            ready <= 0;
            clr_idx <= 0;
            for (i=0; i<BINS; i=i+1) hist[i] <= 0;
        end else begin
            done <= 0;
            case (state)
                S_IDLE: begin
                    busy  <= 0;
                    ready <= 0;
                    if (start) begin
                        clr_idx <= 0;
                        state   <= S_CLEAR;
                        busy    <= 1;
                    end
                end
                S_CLEAR: begin
                    hist[clr_idx] <= 0;
                    clr_idx <= clr_idx + 1;
                    if (clr_idx == BINS-1) begin
                        state <= S_RUN;
                        ready <= 1;
                    end
                end
                S_RUN: begin
                    if (pixel_valid && ready) begin
                        if (pixel_in >= BASE_ADDR && pixel_in < BASE_ADDR+BINS) begin
                            temp_count = hist[pixel_in - BASE_ADDR];
                            hist[pixel_in - BASE_ADDR] <= temp_count + 1'b1;
                        end
                        if (in_last) begin
                            state <= S_DONE;
                            ready <= 0;
                        end
                    end
                end
                S_DONE: begin
                    busy <= 0;
                    done <= 1;
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
