`timescale 1ns / 1ps

module processing_element(
    input  clk,
    input  mod_en, // module enable
    input  stage,  // stage = 1 ise eşik değeri hesaplar; = 0 ise eşikler.
    input  [8:0] pixel_in, // 9-bit pixel değeri
    output [15:0] pack0_o,   // Eşiklenmiş pixel değerleri
    output [15:0] pack1_o,   // Eşiklenmiş pixel değerleri
    output [15:0] pack2_o,   // Eşiklenmiş pixel değerleri
    output [15:0] pack3_o    // Eşiklenmiş pixel değerleri
    );
    
    localparam [3:0]    S0 = 0,
                        S1 = 1,
                        S2 = 2,
                        s3 = 3;
    
    reg [5:0] histogram [0:255]; // local memory
    reg [3:0] state;    // eşik hesaplama durumları için
    reg [8:0] threshold; // eşik değeri
    reg npix; // new pixel (eşikleme sonucu)
    reg [63:0] whole_pack;
    reg [5:0] sayac; // 64 pixel girişi sonrası 
    
    assign {pack0_o,pack1_o,pack2_o,pack3_o} = whole_pack ;
    
    
    always @(posedge clk) begin
        if (stage) begin
            whole_pack <= {npix, whole_pack[63:1]};
        end
    end
    
    integer i;
    
    always @(posedge clk) begin
        if (!mod_en) begin
            state <= 0;
            sayac <= 0;
            for (i = 0; i < 256; i = i + 1) begin
                histogram[i] <= 6'b0;
            end
        end
        else begin
            case (stage)
                1'b0: begin
                    case (state)
                        // Histogram oluşturma
                        S0: begin
                            histogram[pixel_in] <= histogram[pixel_in] + 1;
                            if (sayac == 6'd63) begin
                                sayac <= 0;
                                state <= S1;
                            end
                            else if (sayac < 6'd63) begin
                                sayac <= sayac + 1;
                            end
                        end
                        endcase
                end
                1'b1: begin
                    if (pixel_in < threshold) begin
                        npix <= 0;
                    end
                    else begin
                        npix <= 1;
                    end
                end
            endcase 
        end
    end
    
endmodule
