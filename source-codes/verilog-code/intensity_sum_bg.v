
module intensity_sum_bg (
    input clk,
    input reset,
    input [7:0] i,
    input [31:0] n_i,
    input [7:0] threshold,
    input valid,
    output reg [31:0] sum_bg
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum_bg <= 0;
        end else if (valid) begin
            if (i <= threshold) begin
                sum_bg <= sum_bg + i * n_i;
            end
        end
    end

endmodule