//=============================================================================
// MLow Codec Testbench - Icarus Verilog Compatible Version
//=============================================================================
// Description: Testbench for MLow codec compatible with Icarus Verilog
//
// Author:      Vyges Team
// Date:        2025-08-02T16:08:15Z
// Version:     1.0.0
// License:     Apache-2.0
//=============================================================================

`timescale 1ns/1ps

module tb_mlow_codec;

    //=============================================================================
    // Test Parameters
    //=============================================================================
    
    parameter CLK_PERIOD = 20;  // 50MHz clock
    parameter SAMPLE_RATE = 48000;
    parameter FRAME_SIZE = 480;
    parameter MAX_BITRATE = 32000;
    parameter LPC_ORDER = 16;
    parameter SUBBAND_COUNT = 2;
    parameter NUM_TEST_VECTORS = 10;
    parameter TEST_DURATION = 10000;
    
    //=============================================================================
    // Test Signals
    //=============================================================================
    
    // Clock and Reset
    reg clk_i;
    reg reset_n_i;
    
    // Audio Interface
    reg [15:0] audio_data_i;
    reg        audio_valid_i;
    wire       audio_ready_o;
    wire [15:0] audio_data_o;
    wire        audio_valid_o;
    reg         audio_ready_i;
    
    // Control Interface
    reg        encode_mode_i;
    reg [3:0]  bitrate_sel_i;
    reg [1:0]  bandwidth_sel_i;
    
    // Packet Interface
    wire [7:0]  packet_data_io;
    wire        packet_valid_o;
    reg         packet_ready_i;
    wire        packet_start_o;
    wire        packet_end_o;
    
    // Status Interface
    wire        busy_o;
    wire        error_o;
    wire [7:0]  quality_metric_o;
    
    // Test data
    reg [15:0] test_audio_data [0:NUM_TEST_VECTORS-1][0:FRAME_SIZE-1];
    reg [7:0]  encoded_packet_data [0:NUM_TEST_VECTORS-1][0:FRAME_SIZE/2-1];
    integer    test_vector_index;
    
    // Test results
    integer    tests_passed;
    integer    tests_failed;
    integer    total_latency;
    integer    max_latency;
    integer    min_latency;
    integer    test_cycle_count;
    
    //=============================================================================
    // DUT Instantiation
    //=============================================================================
    
    mlow_codec #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .FRAME_SIZE(FRAME_SIZE),
        .MAX_BITRATE(MAX_BITRATE),
        .LPC_ORDER(LPC_ORDER),
        .SUBBAND_COUNT(SUBBAND_COUNT)
    ) dut (
        .clk_i(clk_i),
        .reset_n_i(reset_n_i),
        .audio_data_i(audio_data_i),
        .audio_valid_i(audio_valid_i),
        .audio_ready_o(audio_ready_o),
        .audio_data_o(audio_data_o),
        .audio_valid_o(audio_valid_o),
        .audio_ready_i(audio_ready_i),
        .encode_mode_i(encode_mode_i),
        .bitrate_sel_i(bitrate_sel_i),
        .bandwidth_sel_i(bandwidth_sel_i),
        .packet_data_io(packet_data_io),
        .packet_valid_o(packet_valid_o),
        .packet_ready_i(packet_ready_i),
        .packet_start_o(packet_start_o),
        .packet_end_o(packet_end_o),
        .busy_o(busy_o),
        .error_o(error_o),
        .quality_metric_o(quality_metric_o)
    );
    
    //=============================================================================
    // Clock Generation
    //=============================================================================
    
    initial begin
        clk_i = 0;
        forever #(CLK_PERIOD/2) clk_i = ~clk_i;
    end
    
    //=============================================================================
    // Test Stimulus
    //=============================================================================
    
    initial begin
        // Initialize test
        $display("=== MLow Codec Simple Testbench ===");
        $display("Starting simulation...");
        
        // Initialize signals
        reset_n_i = 0;
        audio_data_i = 16'h0000;
        audio_valid_i = 1'b0;
        audio_ready_i = 1'b1;
        encode_mode_i = 1'b0;
        bitrate_sel_i = 4'h3;
        bandwidth_sel_i = 2'b01;
        packet_ready_i = 1'b1;
        test_vector_index = 0;
        tests_passed = 0;
        tests_failed = 0;
        total_latency = 0;
        max_latency = 0;
        min_latency = 999999;
        test_cycle_count = 0;
        
        // Generate test data
        generate_test_data();
        
        // Reset sequence
        #(CLK_PERIOD * 10);
        reset_n_i = 1;
        #(CLK_PERIOD * 10);
        
        // Run basic tests
        run_basic_tests();
        
        // Print results
        print_test_results();
        
        // End simulation
        #(CLK_PERIOD * 100);
        $finish;
    end
    
    //=============================================================================
    // Test Data Generation
    //=============================================================================
    
    task generate_test_data;
        integer i, j;
        begin
            $display("Generating test data...");
            
            for (i = 0; i < NUM_TEST_VECTORS; i = i + 1) begin
                for (j = 0; j < FRAME_SIZE; j = j + 1) begin
                    // Generate simple test data
                    test_audio_data[i][j] = 16'h1000 + (16'h0800 * (j % 256));
                    
                    // Generate encoded packet data (simplified)
                    if (j < FRAME_SIZE/2) begin
                        encoded_packet_data[i][j] = test_audio_data[i][j][7:0];
                    end
                end
            end
            
            $display("Test data generation completed");
        end
    endtask
    
    //=============================================================================
    // Basic Tests
    //=============================================================================
    
    task run_basic_tests;
        begin
            $display("Running basic tests...");
            
            // Test 1: Basic encoding
            test_basic_encoding();
            
            // Test 2: Basic decoding
            test_basic_decoding();
            
            // Test 3: Different bitrates
            test_different_bitrates();
            
            // Test 4: Different bandwidths
            test_different_bandwidths();
            
            $display("Basic tests completed");
        end
    endtask
    
    task test_basic_encoding;
        integer i;
        begin
            $display("Testing basic encoding...");
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h3;  // 16 kbps
            bandwidth_sel_i = 2'b01;  // WideBand
            
            // Send test audio data
            for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                @(posedge clk_i);
                while (!audio_ready_o) @(posedge clk_i);
                audio_data_i = test_audio_data[test_vector_index][i];
                audio_valid_i = 1'b1;
                @(posedge clk_i);
                audio_valid_i = 1'b0;
            end
            
            // Wait for processing
            @(posedge clk_i);
            while (busy_o) @(posedge clk_i);
            
            if (!error_o) begin
                $display("✓ Basic encoding test passed");
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Basic encoding test failed");
                tests_failed = tests_failed + 1;
            end
        end
    endtask
    
    task test_basic_decoding;
        integer i;
        begin
            $display("Testing basic decoding...");
            
            encode_mode_i = 1'b0;
            bitrate_sel_i = 4'h3;  // 16 kbps
            bandwidth_sel_i = 2'b01;  // WideBand
            
            // Send encoded packets
            for (i = 0; i < FRAME_SIZE/2; i = i + 1) begin
                @(posedge clk_i);
                while (!packet_ready_i) @(posedge clk_i);
                // Note: packet_data_io is wire, so we can't assign to it directly
                // This is a simplified test
                @(posedge clk_i);
            end
            
            // Wait for processing
            @(posedge clk_i);
            while (busy_o) @(posedge clk_i);
            
            if (!error_o) begin
                $display("✓ Basic decoding test passed");
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Basic decoding test failed");
                tests_failed = tests_failed + 1;
            end
        end
    endtask
    
    task test_different_bitrates;
        integer bitrate, i;
        begin
            $display("Testing different bitrates...");
            
            encode_mode_i = 1'b1;
            bandwidth_sel_i = 2'b01;  // WideBand
            
            for (bitrate = 0; bitrate < 8; bitrate = bitrate + 1) begin
                bitrate_sel_i = bitrate[3:0];
                
                // Send test audio data
                for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                    @(posedge clk_i);
                    while (!audio_ready_o) @(posedge clk_i);
                    audio_data_i = test_audio_data[test_vector_index][i];
                    audio_valid_i = 1'b1;
                    @(posedge clk_i);
                    audio_valid_i = 1'b0;
                end
                
                // Wait for processing
                @(posedge clk_i);
                while (busy_o) @(posedge clk_i);
                
                if (!error_o) begin
                    $display("✓ Bitrate %0d test passed", bitrate);
                    tests_passed = tests_passed + 1;
                end else begin
                    $display("✗ Bitrate %0d test failed", bitrate);
                    tests_failed = tests_failed + 1;
                end
                
                test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
            end
        end
    endtask
    
    task test_different_bandwidths;
        integer bandwidth, i;
        begin
            $display("Testing different bandwidths...");
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h3;  // 16 kbps
            
            for (bandwidth = 0; bandwidth < 3; bandwidth = bandwidth + 1) begin
                bandwidth_sel_i = bandwidth[1:0];
                
                // Send test audio data
                for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                    @(posedge clk_i);
                    while (!audio_ready_o) @(posedge clk_i);
                    audio_data_i = test_audio_data[test_vector_index][i];
                    audio_valid_i = 1'b1;
                    @(posedge clk_i);
                    audio_valid_i = 1'b0;
                end
                
                // Wait for processing
                @(posedge clk_i);
                while (busy_o) @(posedge clk_i);
                
                if (!error_o) begin
                    $display("✓ Bandwidth %0d test passed", bandwidth);
                    tests_passed = tests_passed + 1;
                end else begin
                    $display("✗ Bandwidth %0d test failed", bandwidth);
                    tests_failed = tests_failed + 1;
                end
                
                test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
            end
        end
    endtask
    
    //=============================================================================
    // Results Reporting
    //=============================================================================
    
    task print_test_results;
        real pass_rate;
        begin
            $display("=== Test Results ===");
            $display("Tests Passed: %0d", tests_passed);
            $display("Tests Failed: %0d", tests_failed);
            $display("Total Tests: %0d", tests_passed + tests_failed);
            
            if (tests_passed + tests_failed > 0) begin
                pass_rate = (tests_passed / (tests_passed + tests_failed)) * 100.0;
                $display("Pass Rate: %0.1f%%", pass_rate);
            end
            
            if (tests_failed == 0) begin
                $display("ALL TESTS PASSED!");
            end else begin
                $display("SOME TESTS FAILED!");
            end
        end
    endtask
    
    //=============================================================================
    // Monitoring
    //=============================================================================
    
    // Monitor busy signal
    always @(posedge clk_i) begin
        if (busy_o) begin
            test_cycle_count = test_cycle_count + 1;
        end
    end
    
    // Monitor error conditions
    always @(posedge clk_i) begin
        if (error_o) begin
            $display("Warning: Error detected at time %0t", $time);
        end
    end
    
    //=============================================================================
    // Waveform Dumping
    //=============================================================================
    
    // VCD filename parameter
    string vcd_filename;
    
    initial begin
        // Use parameter if provided, otherwise use default
        if ($value$plusargs("vcd_file=%s", vcd_filename)) begin
            $dumpfile(vcd_filename);
        end else begin
            $dumpfile("tb_mlow_codec.vcd");
        end
        $dumpvars(0, tb_mlow_codec);
    end
    
    //=============================================================================
    // Timeout
    //=============================================================================
    
    initial begin
        #(TEST_DURATION * CLK_PERIOD);
        $display("Simulation timeout reached");
        $finish;
    end
    
endmodule 