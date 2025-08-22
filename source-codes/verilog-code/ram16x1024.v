`timescale 1ns / 1ps

// Sabit boyutu/büyüklüğü olan ram tasarımı

module ram16x1024(
    input clk,
    input mod_en,   // Bu modülün seçilmesi
    input wr_en,    // Yazma enable
    input rd_en,    // Okuma enable
    input [9:0] addr_in,  // Yazılacak adres
    input [15:0] data_in,  // Yazılacak data
    output [15:0] data_o   // Okunacak data
    );
    
    reg [15:0] ram [1023:0];    // 16-bit 1024 satır
    reg [15:0] data_out;
    
    assign data_o = data_out;
    
    always @(posedge clk) begin
        if (mod_en) begin
        // Data yazma wr_en = 1 ve rd_en = 0
            if (wr_en && !rd_en) begin
                ram[addr_in] <= data_in;
            end
        // Data okuma wr_en = 0 ve rd_en = 1
            if (!wr_en && rd_en) begin
                data_out <= ram[addr_in];
            end
        end
    end
        
endmodule
