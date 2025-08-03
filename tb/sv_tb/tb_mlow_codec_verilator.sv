//=============================================================================
// MLow Codec Testbench - Verilator Compatible Version
//=============================================================================
// Description: Testbench for MLow codec compatible with Verilator
//              Uses simplified approach - no event controls inside tasks
//
// Author:      Vyges Team
// Date:        2025-08-02T16:08:15Z
// Version:     1.0.0
// License:     Apache-2.0
//=============================================================================

`timescale 1ns/1ps

module tb_mlow_codec_verilator;

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
    // Test States
    //=============================================================================
    
    typedef enum logic [3:0] {
        INIT,
        RESET_WAIT,
        IDLE,
        TEST_ENCODING,
        TEST_DECODING,
        TEST_BITRATES,
        TEST_BANDWIDTHS,
        WAIT_READY,
        WAIT_BUSY,
        DONE
    } test_state_t;
    
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
    integer    test_cycle_count;
    
    // Clock counter for timing
    integer    clock_count;
    
    // Test state machine
    test_state_t test_state;
    integer      test_counter;
    integer      wait_counter;
    integer      current_test;
    integer      current_bitrate;
    integer      current_bandwidth;
    integer      current_sample;
    
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
        clock_count = 0;
    end
    
    always begin
        #(CLK_PERIOD/2) clk_i = ~clk_i;
        clock_count = clock_count + 1;
    end
    
    //=============================================================================
    // Test Data Generation
    //=============================================================================
    
    initial begin
        generate_test_data();
    end
    
    task generate_test_data;
        integer i, j;
        begin
            $display("Generating test data...");
            
            for (i = 0; i < NUM_TEST_VECTORS; i = i + 1) begin
                for (j = 0; j < FRAME_SIZE; j = j + 1) begin
                    // Simple test pattern
                    test_audio_data[i][j] = 16'h1000 + (16'h0800 * (j % 256));
                end
            end
            
            $display("Test data generation completed");
        end
    endtask
    
    //=============================================================================
    // Main Test State Machine
    //=============================================================================
    
    initial begin
        $display("=== MLow Codec Verilator Testbench ===");
        $display("Starting simulation...");
        
        // Initialize
        test_state = INIT;
        test_counter = 0;
        wait_counter = 0;
        current_test = 0;
        current_bitrate = 0;
        current_bandwidth = 0;
        current_sample = 0;
        
        // Initialize signals
        reset_n_i = 1'b0;
        audio_data_i = 16'h0000;
        audio_valid_i = 1'b0;
        audio_ready_i = 1'b1;
        encode_mode_i = 1'b0;
        bitrate_sel_i = 4'h0;
        bandwidth_sel_i = 2'b00;
        packet_ready_i = 1'b1;
        
        // Initialize counters
        tests_passed = 0;
        tests_failed = 0;
        test_cycle_count = 0;
        test_vector_index = 0;
    end
    
    // Main test state machine - FFT repo style
    always_ff @(posedge clk_i) begin
        case (test_state)
            INIT: begin
                // Wait for initial setup
                if (test_counter >= 5) begin
                    test_state <= RESET_WAIT;
                    test_counter <= 0;
                end else begin
                    test_counter <= test_counter + 1;
                end
            end
            
            RESET_WAIT: begin
                // Reset sequence
                if (test_counter < 10) begin
                    reset_n_i <= 1'b0;
                    test_counter <= test_counter + 1;
                end else if (test_counter < 15) begin
                    reset_n_i <= 1'b1;
                    test_counter <= test_counter + 1;
                end else begin
                    test_state <= IDLE;
                    test_counter <= 0;
                end
            end
            
            IDLE: begin
                // Start first test
                test_state <= TEST_ENCODING;
                current_test <= 0;
                test_counter <= 0;
            end
            
            TEST_ENCODING: begin
                case (test_counter)
                    0: begin
                        // Setup encoding test
                        encode_mode_i <= 1'b1;
                        bitrate_sel_i <= 4'h3;  // 16 kbps
                        bandwidth_sel_i <= 2'b01;  // WideBand
                        current_sample <= 0;
                        test_counter <= test_counter + 1;
                    end
                    1: begin
                        // Send audio data
                        if (current_sample < FRAME_SIZE) begin
                            if (audio_ready_o) begin
                                audio_data_i <= test_audio_data[test_vector_index][current_sample];
                                audio_valid_i <= 1'b1;
                                current_sample <= current_sample + 1;
                            end
                        end else begin
                            audio_valid_i <= 1'b0;
                            test_state <= WAIT_BUSY;
                            test_counter <= 0;
                        end
                    end
                endcase
            end
            
            WAIT_BUSY: begin
                // Wait for processing to complete
                if (!busy_o) begin
                    if (!error_o) begin
                        $display("✓ Basic encoding test passed");
                        tests_passed <= tests_passed + 1;
                    end else begin
                        $display("✗ Basic encoding test failed");
                        tests_failed <= tests_failed + 1;
                    end
                    test_state <= TEST_DECODING;
                    test_counter <= 0;
                end
            end
            
            TEST_DECODING: begin
                case (test_counter)
                    0: begin
                        // Setup decoding test
                        encode_mode_i <= 1'b0;
                        bitrate_sel_i <= 4'h3;  // 16 kbps
                        bandwidth_sel_i <= 2'b01;  // WideBand
                        current_sample <= 0;
                        test_counter <= test_counter + 1;
                    end
                    1: begin
                        // Simulate packet reception
                        if (current_sample < FRAME_SIZE/2) begin
                            if (packet_ready_i) begin
                                current_sample <= current_sample + 1;
                            end
                        end else begin
                            test_state <= WAIT_BUSY;
                            test_counter <= 0;
                        end
                    end
                endcase
            end
            
            TEST_BITRATES: begin
                case (test_counter)
                    0: begin
                        // Setup bitrate test
                        if (current_bitrate < 8) begin
                            encode_mode_i <= 1'b1;
                            bitrate_sel_i <= current_bitrate[3:0];
                            bandwidth_sel_i <= 2'b01;  // WideBand
                            current_sample <= 0;
                            test_counter <= test_counter + 1;
                        end else begin
                            test_state <= TEST_BANDWIDTHS;
                            test_counter <= 0;
                            current_bitrate <= 0;
                        end
                    end
                    1: begin
                        // Send audio data for current bitrate
                        if (current_sample < FRAME_SIZE) begin
                            if (audio_ready_o) begin
                                audio_data_i <= test_audio_data[test_vector_index][current_sample];
                                audio_valid_i <= 1'b1;
                                current_sample <= current_sample + 1;
                            end
                        end else begin
                            audio_valid_i <= 1'b0;
                            test_state <= WAIT_BUSY;
                            test_counter <= 0;
                        end
                    end
                endcase
            end
            
            TEST_BANDWIDTHS: begin
                case (test_counter)
                    0: begin
                        // Setup bandwidth test
                        if (current_bandwidth < 3) begin
                            encode_mode_i <= 1'b1;
                            bitrate_sel_i <= 4'h3;  // 16 kbps
                            bandwidth_sel_i <= current_bandwidth[1:0];
                            current_sample <= 0;
                            test_counter <= test_counter + 1;
                        end else begin
                            test_state <= DONE;
                            test_counter <= 0;
                        end
                    end
                    1: begin
                        // Send audio data for current bandwidth
                        if (current_sample < FRAME_SIZE) begin
                            if (audio_ready_o) begin
                                audio_data_i <= test_audio_data[test_vector_index][current_sample];
                                audio_valid_i <= 1'b1;
                                current_sample <= current_sample + 1;
                            end
                        end else begin
                            audio_valid_i <= 1'b0;
                            test_state <= WAIT_BUSY;
                            test_counter <= 0;
                        end
                    end
                endcase
            end
            
            DONE: begin
                // Print results and finish
                print_test_results();
                $finish;
            end
            
            default: begin
                test_state <= INIT;
            end
        endcase
    end
    
    // Handle busy wait completion
    always_ff @(posedge clk_i) begin
        if (test_state == WAIT_BUSY && !busy_o) begin
            case (current_test)
                0: begin // Encoding test completed
                    current_test <= 1;
                    test_state <= TEST_DECODING;
                end
                1: begin // Decoding test completed
                    current_test <= 2;
                    test_state <= TEST_BITRATES;
                end
                2: begin // Bitrate test completed
                    if (!error_o) begin
                        $display("✓ Bitrate %0d test passed", current_bitrate);
                        tests_passed <= tests_passed + 1;
                    end else begin
                        $display("✗ Bitrate %0d test failed", current_bitrate);
                        tests_failed <= tests_failed + 1;
                    end
                    current_bitrate <= current_bitrate + 1;
                    test_vector_index <= (test_vector_index + 1) % NUM_TEST_VECTORS;
                    test_state <= TEST_BITRATES;
                end
                3: begin // Bandwidth test completed
                    if (!error_o) begin
                        $display("✓ Bandwidth %0d test passed", current_bandwidth);
                        tests_passed <= tests_passed + 1;
                    end else begin
                        $display("✗ Bandwidth %0d test failed", current_bandwidth);
                        tests_failed <= tests_failed + 1;
                    end
                    current_bandwidth <= current_bandwidth + 1;
                    test_vector_index <= (test_vector_index + 1) % NUM_TEST_VECTORS;
                    test_state <= TEST_BANDWIDTHS;
                end
            endcase
        end
    end
    
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
            // Use relative path from simulation directory
            $dumpfile("../../build/waveforms/tb_mlow_codec_verilator.vcd");
        end
        $dumpvars(0, tb_mlow_codec_verilator);
    end
    
    //=============================================================================
    // Timeout Protection (removed for Verilator compatibility)
    //=============================================================================
    
    // Note: Timeout protection removed to avoid event control issues with Verilator
    // The testbench will finish naturally when all tests complete
    
endmodule 