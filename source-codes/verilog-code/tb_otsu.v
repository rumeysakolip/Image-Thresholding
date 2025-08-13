`timescale 1ns/1ps

module tb_otsu();

    // System Signals
    reg clk;
    reg reset;
    
    // Memory Interface
    reg [7:0] mem_data_in = 0;
    wire [31:0] mem_addr;
    wire mem_rw;
    wire mem_en;
    wire [7:0] mem_data_out;
    wire processing_done;
    
    // Debug Outputs
    wire [3:0] fifo_rd_en_obs;
    wire [7:0] threshold_obs;
    wire [3:0] pixel_out_obs;
    
    // Test Image (8x8 = 64 pixels)
    reg [7:0] test_img [0:63];
    reg [7:0] out_binary [0:7];

    // Initialize all outputs
    initial begin
        foreach(out_binary[i]) out_binary[i] = 0;
    end

    // DUT Instantiation
    otsu_top #(
        .IMAGE_WIDTH(8),
        .IMAGE_HEIGHT(8)
    ) dut (
        .clk(clk),
        .reset(reset),
        .mem_data_in(mem_data_in),
        .mem_addr(mem_addr),
        .mem_rw(mem_rw),
        .mem_en(mem_en),
        .mem_data_out(mem_data_out),
        .processing_done(processing_done),
        .fifo_rd_en_obs(fifo_rd_en_obs),
        .threshold_obs(threshold_obs),
        .pixel_out_obs(pixel_out_obs)
    );

    // 100MHz Clock with X-state avoidance
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Enhanced Test Sequence
    initial begin
        $display("Starting Testbench");
        
        // Initialize memory with known pattern
        $display("Initializing test image...");
        for (int i=0; i<64; i++) begin
            test_img[i] = (i % 8 < 4) ? 8'h3F : 8'hC0; // Vertical split
        end
        
        // Apply proper reset sequence
        $display("Applying reset...");
        reset = 1'b1;
        #100;
        reset = 1'b0;
        #10;
        
        // Monitor critical signals
        fork
            // Timeout checker
            begin
                #1000;
                $display("\nERROR: Simulation timeout!");
                $display("Current state:");
                $display("mem_en: %b, mem_rw: %b", mem_en, mem_rw);
                $display("processing_done: %b", processing_done);
                $display("fifo_rd_en_obs: %b", fifo_rd_en_obs);
                $finish;
            end
            
            // Signal monitor
            begin
                forever @(posedge clk) begin
                    if (mem_en) begin
                        $display("[%0t] Addr:%h Data:%h R/W:%b", 
                                $time, mem_addr, 
                                mem_rw ? mem_data_out : mem_data_in, 
                                mem_rw);
                    end
                end
            end
        join_none
        
        // Wait for completion
        wait(processing_done);
        #100;
        
        // Verify results
        print_results();
        $finish;
    end

    // Memory Interface with X-protection
    always @(posedge clk) begin
        if (mem_en && !mem_rw) begin
            if (mem_addr < 64) begin
                mem_data_in <= test_img[mem_addr];
                $display("Memory Read: Addr:%h Data:%h", 
                        mem_addr, test_img[mem_addr]);
            end else begin
                mem_data_in <= 8'hFF;
                $display("WARNING: Out-of-bounds read at %h", mem_addr);
            end
        end
    end

    always @(posedge clk) begin
        if (mem_en && mem_rw) begin
            if ((mem_addr >= 32'h00100000) && 
                (mem_addr <= 32'h00100007)) begin
                out_binary[mem_addr - 32'h00100000] <= mem_data_out;
                $display("Memory Write: Addr:%h Data:%h", 
                        mem_addr, mem_data_out);
            end else begin
                $display("ERROR: Invalid write to %h", mem_addr);
            end
        end
    end

    task print_results;
        begin
            $display("\n=== FINAL RESULTS ===");
            $display("Threshold: %h", threshold_obs);
            $display("Output Binary:");
            for (int i=0; i<8; i++) begin
                $display("Byte %0d: %8b", i, out_binary[i]);
            end
            
            // Check first and last bytes
            if (out_binary[0][3:0] === 4'b0000 && 
                out_binary[7][7:4] === 4'b1111) begin
                $display("TEST PASSED");
            end else begin
                $display("TEST FAILED");
            end
        end
    endtask

endmodule
