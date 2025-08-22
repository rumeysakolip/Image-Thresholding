module dual_read_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 4
) (
    input wire clk,
    input wire reset,
    input wire write_en,
    input wire read_en,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out,
    output wire fifo_full,
    output wire fifo_empty,
    output reg second_pass_active
);

localparam FIFO_ADDR_WIDTH = $clog2(FIFO_DEPTH);
reg [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
reg [FIFO_ADDR_WIDTH:0] write_ptr;
reg [FIFO_ADDR_WIDTH:0] read_ptr;
reg read_pass;

// Write Logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        write_ptr <= 0;
    end
    else if (write_en && !fifo_full) begin
        fifo_mem[write_ptr[FIFO_ADDR_WIDTH-1:0]] <= data_in;
        write_ptr <= write_ptr + 1;
    end
end

// Read Logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        read_ptr <= 0;
        read_pass <= 0;
        data_out <= 0;
        second_pass_active <= 0;
    end
    else if (read_en && !fifo_empty) begin
        data_out <= fifo_mem[read_ptr[FIFO_ADDR_WIDTH-1:0]];
        
        if (read_ptr[FIFO_ADDR_WIDTH-1:0] == FIFO_DEPTH-1) begin
            read_ptr <= 0;
            read_pass <= ~read_pass;
            second_pass_active <= read_pass;
        end
        else begin
            read_ptr <= read_ptr + 1;
        end
    end
end

// Status Flags
assign fifo_full = ((write_ptr[FIFO_ADDR_WIDTH] != read_ptr[FIFO_ADDR_WIDTH]) &&
                   (write_ptr[FIFO_ADDR_WIDTH-1:0] == read_ptr[FIFO_ADDR_WIDTH-1:0]));

assign fifo_empty = (write_ptr == read_ptr) && (read_pass == 0);  // FIXED: Only empty after 2 passes

endmodule