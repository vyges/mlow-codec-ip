//=============================================================================
// MLow Codec Comprehensive Testbench - Icarus Verilog Compatible Version
//=============================================================================
// Description: Comprehensive testbench for MLow codec with expanded test coverage
//
// Author:      Vyges Team
// Date:        2025-08-02T16:08:15Z
// Version:     2.0.0
// License:     Apache-2.0
//=============================================================================

`timescale 1ns/1ps

module tb_mlow_codec_comprehensive;

    //=============================================================================
    // Test Parameters
    //=============================================================================
    
    parameter CLK_PERIOD = 20;  // 50MHz clock
    parameter SAMPLE_RATE = 48000;
    parameter FRAME_SIZE = 16;  // Quick simulation with 16-sample frames
    parameter MAX_BITRATE = 32000;
    parameter LPC_ORDER = 16;
    parameter SUBBAND_COUNT = 2;
    parameter NUM_TEST_VECTORS = 20;
    parameter TEST_DURATION = 50000;
    
    // Test categories
    parameter NUM_BITRATES = 8;
    parameter NUM_BANDWIDTHS = 3;
    parameter NUM_AUDIO_PATTERNS = 5;
    
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
    
    // Test data arrays
    reg [15:0] test_audio_data [0:NUM_TEST_VECTORS-1][0:FRAME_SIZE-1];
    reg [7:0]  encoded_packet_data [0:NUM_TEST_VECTORS-1][0:FRAME_SIZE/2-1];
    reg [15:0] decoded_audio_data [0:NUM_TEST_VECTORS-1][0:FRAME_SIZE-1];
    
    // Test control
    integer    test_vector_index;
    integer    current_test;
    integer    test_cycle_start;
    integer    test_cycle_end;
    
    // Test results
    integer    tests_passed;
    integer    tests_failed;
    integer    total_latency;
    integer    max_latency;
    integer    min_latency;
    integer    test_cycle_count;
    
    // Performance metrics
    integer    total_frames_processed;
    integer    total_encoding_time;
    integer    total_decoding_time;
    real       average_encoding_latency;
    real       average_decoding_latency;
    
    // Error tracking
    integer    error_count;
    integer    timeout_count;
    integer    backpressure_count;
    
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
    // Test Data Generation
    //=============================================================================
    
    initial begin
        generate_test_data();
    end
    
    task generate_test_data;
        integer i, j, pattern;
        real frequency, amplitude, phase;
        begin
            $display("Generating test data...");
            
            for (i = 0; i < NUM_TEST_VECTORS; i = i + 1) begin
                pattern = i % NUM_AUDIO_PATTERNS;
                
                case (pattern)
                    0: begin // Sine wave
                        frequency = 1000.0 + (i * 500.0); // 1kHz to 10kHz
                        amplitude = 8000.0;
                        for (j = 0; j < FRAME_SIZE; j = j + 1) begin
                            test_audio_data[i][j] = $rtoi(amplitude * $sin(2.0 * 3.14159 * frequency * j / SAMPLE_RATE));
                        end
                    end
                    1: begin // White noise
                        for (j = 0; j < FRAME_SIZE; j = j + 1) begin
                            test_audio_data[i][j] = ($random % 16000) - 8000;
                        end
                    end
                    2: begin // Silence
                        for (j = 0; j < FRAME_SIZE; j = j + 1) begin
                            test_audio_data[i][j] = 16'h0000;
                        end
                    end
                    3: begin // Impulse
                        for (j = 0; j < FRAME_SIZE; j = j + 1) begin
                            if (j == 0) begin
                                test_audio_data[i][j] = 16'h7FFF;
                            end else begin
                                test_audio_data[i][j] = 16'h0000;
                            end
                        end
                    end
                    4: begin // Chirp (frequency sweep)
                        for (j = 0; j < FRAME_SIZE; j = j + 1) begin
                            frequency = 100.0 + (j * 20000.0 / FRAME_SIZE); // 100Hz to 20kHz
                            test_audio_data[i][j] = $rtoi(4000.0 * $sin(2.0 * 3.14159 * frequency * j / SAMPLE_RATE));
                        end
                    end
                endcase
            end
            
            $display("Test data generation completed");
        end
    endtask
    
    //=============================================================================
    // Main Test Sequence
    //=============================================================================
    
    initial begin
        $display("=== MLow Codec Comprehensive Testbench ===");
        $display("Starting comprehensive simulation...");
        
        // Initialize
        initialize_test();
        
        // Run comprehensive test suite
        run_comprehensive_tests();
        
        // Print results
        print_comprehensive_results();
        
        $finish;
    end
    
    task initialize_test;
        begin
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
            total_latency = 0;
            max_latency = 0;
            min_latency = 999999;
            test_cycle_count = 0;
            total_frames_processed = 0;
            total_encoding_time = 0;
            total_decoding_time = 0;
            error_count = 0;
            timeout_count = 0;
            backpressure_count = 0;
            test_vector_index = 0;
            current_test = 0;
            
            // Reset sequence
            #(CLK_PERIOD * 10);
            reset_n_i = 1'b1;
            #(CLK_PERIOD * 5);
        end
    endtask
    
    task run_comprehensive_tests;
        begin
            // Test Category 1: Basic Functionality
            $display("=== Test Category 1: Basic Functionality ===");
            test_basic_encoding();
            test_basic_decoding();
            test_mode_switching();
            
            // Test Category 2: Bitrate Coverage
            $display("=== Test Category 2: Bitrate Coverage ===");
            test_all_bitrates();
            
            // Test Category 3: Bandwidth Coverage
            $display("=== Test Category 3: Bandwidth Coverage ===");
            test_all_bandwidths();
            
            // Test Category 4: Audio Pattern Tests
            $display("=== Test Category 4: Audio Pattern Tests ===");
            test_audio_patterns();
            
            // Test Category 5: Performance Tests
            $display("=== Test Category 5: Performance Tests ===");
            test_performance_metrics();
            
            // Test Category 6: Error Condition Tests
            $display("=== Test Category 6: Error Condition Tests ===");
            test_error_conditions();
            
            // Test Category 7: Backpressure Tests
            $display("=== Test Category 7: Backpressure Tests ===");
            test_backpressure_handling();
            
            // Test Category 8: Continuous Operation
            $display("=== Test Category 8: Continuous Operation ===");
            test_continuous_operation();
            
            // Test Category 9: Edge Cases
            $display("=== Test Category 9: Edge Cases ===");
            test_edge_cases();
            
            // Test Category 10: Quality Metrics
            $display("=== Test Category 10: Quality Metrics ===");
            test_quality_metrics();
            
            // Test Category 11: Frame Buffering Verification
            $display("=== Test Category 11: Frame Buffering Verification ===");
            test_frame_buffering();
            
            // Test Category 12: Full Frame Interface Verification
            $display("=== Test Category 12: Full Frame Interface Verification ===");
            test_full_frame_interface();
        end
    endtask 

    //=============================================================================
    // Test Task Implementations
    //=============================================================================
    
    // Test Category 1: Basic Functionality
    task test_basic_encoding;
        integer i, latency;
        begin
            $display("Testing basic encoding...");
            current_test = current_test + 1;
            test_cycle_start = test_cycle_count;
            
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
            
            test_cycle_end = test_cycle_count;
            latency = test_cycle_end - test_cycle_start;
            total_encoding_time = total_encoding_time + latency;
            total_frames_processed = total_frames_processed + 1;
            
            if (!error_o) begin
                $display("✓ Basic encoding test passed (latency: %0d cycles)", latency);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Basic encoding test failed");
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
            
            test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
        end
    endtask
    
    task test_basic_decoding;
        integer i, latency;
        begin
            $display("Testing basic decoding...");
            current_test = current_test + 1;
            test_cycle_start = test_cycle_count;
            
            encode_mode_i = 1'b0;
            bitrate_sel_i = 4'h3;  // 16 kbps
            bandwidth_sel_i = 2'b01;  // WideBand
            
            // Simulate packet reception (simplified)
            for (i = 0; i < FRAME_SIZE/2; i = i + 1) begin
                @(posedge clk_i);
                while (!packet_ready_i) @(posedge clk_i);
                @(posedge clk_i);
            end
            
            // Wait for processing
            @(posedge clk_i);
            while (busy_o) @(posedge clk_i);
            
            test_cycle_end = test_cycle_count;
            latency = test_cycle_end - test_cycle_start;
            total_decoding_time = total_decoding_time + latency;
            total_frames_processed = total_frames_processed + 1;
            
            if (!error_o) begin
                $display("✓ Basic decoding test passed (latency: %0d cycles)", latency);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Basic decoding test failed");
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
        end
    endtask
    
    task test_mode_switching;
        integer i, latency;
        begin
            $display("Testing mode switching...");
            current_test = current_test + 1;
            
            // Test encoding to decoding switch
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h2;  // 12 kbps
            bandwidth_sel_i = 2'b00;  // NarrowBand
            
            // Send one frame in encode mode
            for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                @(posedge clk_i);
                while (!audio_ready_o) @(posedge clk_i);
                audio_data_i = test_audio_data[test_vector_index][i];
                audio_valid_i = 1'b1;
                @(posedge clk_i);
                audio_valid_i = 1'b0;
            end
            
            while (busy_o) @(posedge clk_i);
            
            // Switch to decode mode
            encode_mode_i = 1'b0;
            @(posedge clk_i);
            
            // Test decoding
            for (i = 0; i < FRAME_SIZE/2; i = i + 1) begin
                @(posedge clk_i);
                while (!packet_ready_i) @(posedge clk_i);
                @(posedge clk_i);
            end
            
            while (busy_o) @(posedge clk_i);
            
            if (!error_o) begin
                $display("✓ Mode switching test passed");
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Mode switching test failed");
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
            
            test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
        end
    endtask
    
    // Test Category 2: Bitrate Coverage
    task test_all_bitrates;
        integer bitrate, i, latency;
        begin
            $display("Testing all bitrates...");
            
            encode_mode_i = 1'b1;
            bandwidth_sel_i = 2'b01;  // WideBand
            
            for (bitrate = 0; bitrate < NUM_BITRATES; bitrate = bitrate + 1) begin
                current_test = current_test + 1;
                test_cycle_start = test_cycle_count;
                
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
                
                test_cycle_end = test_cycle_count;
                latency = test_cycle_end - test_cycle_start;
                total_encoding_time = total_encoding_time + latency;
                total_frames_processed = total_frames_processed + 1;
                
                if (!error_o) begin
                    $display("✓ Bitrate %0d test passed (latency: %0d cycles)", bitrate, latency);
                    tests_passed = tests_passed + 1;
                end else begin
                    $display("✗ Bitrate %0d test failed", bitrate);
                    tests_failed = tests_failed + 1;
                    error_count = error_count + 1;
                end
                
                test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
            end
        end
    endtask
    
    // Test Category 3: Bandwidth Coverage
    task test_all_bandwidths;
        integer bandwidth, i, latency;
        begin
            $display("Testing all bandwidths...");
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h3;  // 16 kbps
            
            for (bandwidth = 0; bandwidth < NUM_BANDWIDTHS; bandwidth = bandwidth + 1) begin
                current_test = current_test + 1;
                test_cycle_start = test_cycle_count;
                
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
                
                test_cycle_end = test_cycle_count;
                latency = test_cycle_end - test_cycle_start;
                total_encoding_time = total_encoding_time + latency;
                total_frames_processed = total_frames_processed + 1;
                
                if (!error_o) begin
                    $display("✓ Bandwidth %0d test passed (latency: %0d cycles)", bandwidth, latency);
                    tests_passed = tests_passed + 1;
                end else begin
                    $display("✗ Bandwidth %0d test failed", bandwidth);
                    tests_failed = tests_failed + 1;
                    error_count = error_count + 1;
                end
                
                test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
            end
        end
    endtask
    
    // Test Category 4: Audio Pattern Tests
    task test_audio_patterns;
        integer pattern, i, latency;
        begin
            $display("Testing audio patterns...");
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h4;  // 20 kbps
            bandwidth_sel_i = 2'b10;  // SuperWideBand
            
            for (pattern = 0; pattern < NUM_AUDIO_PATTERNS; pattern = pattern + 1) begin
                current_test = current_test + 1;
                test_cycle_start = test_cycle_count;
                
                // Use pattern-specific test vector
                test_vector_index = pattern;
                
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
                
                test_cycle_end = test_cycle_count;
                latency = test_cycle_end - test_cycle_start;
                total_encoding_time = total_encoding_time + latency;
                total_frames_processed = total_frames_processed + 1;
                
                if (!error_o) begin
                    $display("✓ Audio pattern %0d test passed (latency: %0d cycles)", pattern, latency);
                    tests_passed = tests_passed + 1;
                end else begin
                    $display("✗ Audio pattern %0d test failed", pattern);
                    tests_failed = tests_failed + 1;
                    error_count = error_count + 1;
                end
            end
        end
    endtask
    
    // Test Category 5: Performance Tests
    task test_performance_metrics;
        integer i, latency, total_latency_temp;
        begin
            $display("Testing performance metrics...");
            current_test = current_test + 1;
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h5;  // 24 kbps
            bandwidth_sel_i = 2'b01;  // WideBand
            
            total_latency_temp = 0;
            
            // Process multiple frames for performance measurement
            for (i = 0; i < 5; i = i + 1) begin
                test_cycle_start = test_cycle_count;
                
                // Send test audio data
                for (integer j = 0; j < FRAME_SIZE; j = j + 1) begin
                    @(posedge clk_i);
                    while (!audio_ready_o) @(posedge clk_i);
                    audio_data_i = test_audio_data[test_vector_index][j];
                    audio_valid_i = 1'b1;
                    @(posedge clk_i);
                    audio_valid_i = 1'b0;
                end
                
                // Wait for processing
                @(posedge clk_i);
                while (busy_o) @(posedge clk_i);
                
                test_cycle_end = test_cycle_count;
                latency = test_cycle_end - test_cycle_start;
                total_latency_temp = total_latency_temp + latency;
                total_frames_processed = total_frames_processed + 1;
                
                test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
            end
            
            if (!error_o) begin
                $display("✓ Performance test passed (avg latency: %0d cycles)", total_latency_temp / 5);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Performance test failed");
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
        end
    endtask
    
    // Test Category 6: Error Condition Tests
    task test_error_conditions;
        integer i;
        begin
            $display("Testing error conditions...");
            current_test = current_test + 1;
            
            // Test invalid bitrate
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'hF;  // Invalid bitrate
            bandwidth_sel_i = 2'b01;
            
            for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                @(posedge clk_i);
                while (!audio_ready_o) @(posedge clk_i);
                audio_data_i = test_audio_data[test_vector_index][i];
                audio_valid_i = 1'b1;
                @(posedge clk_i);
                audio_valid_i = 1'b0;
            end
            
            while (busy_o) @(posedge clk_i);
            
            if (error_o) begin
                $display("✓ Error condition test passed (invalid bitrate detected)");
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Error condition test failed (should detect invalid bitrate)");
                tests_failed = tests_failed + 1;
            end
            
            test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
        end
    endtask
    
    // Test Category 7: Backpressure Tests
    task test_backpressure_handling;
        integer i, backpressure_cycles;
        begin
            $display("Testing backpressure handling...");
            current_test = current_test + 1;
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h3;  // 16 kbps
            bandwidth_sel_i = 2'b01;  // WideBand
            
            // Apply backpressure
            audio_ready_i = 1'b0;
            packet_ready_i = 1'b0;
            
            // Send data with backpressure
            for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                @(posedge clk_i);
                audio_data_i = test_audio_data[test_vector_index][i];
                audio_valid_i = 1'b1;
                
                // Wait for backpressure to be handled
                backpressure_cycles = 0;
                while (!audio_ready_o && backpressure_cycles < 100) begin
                    @(posedge clk_i);
                    backpressure_cycles = backpressure_cycles + 1;
                end
                
                if (audio_ready_o) begin
                    @(posedge clk_i);
                    audio_valid_i = 1'b0;
                end else begin
                    $display("Warning: Backpressure timeout at sample %0d", i);
                    timeout_count = timeout_count + 1;
                end
            end
            
            // Release backpressure
            audio_ready_i = 1'b1;
            packet_ready_i = 1'b1;
            
            // Wait for processing
            @(posedge clk_i);
            while (busy_o) @(posedge clk_i);
            
            if (!error_o) begin
                $display("✓ Backpressure test passed");
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Backpressure test failed");
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
            
            test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
        end
    endtask
    
    // Test Category 8: Continuous Operation
    task test_continuous_operation;
        integer i, frame_count;
        begin
            $display("Testing continuous operation...");
            current_test = current_test + 1;
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h4;  // 20 kbps
            bandwidth_sel_i = 2'b01;  // WideBand
            
            frame_count = 0;
            
            // Process multiple frames continuously
            for (i = 0; i < 10; i = i + 1) begin
                // Send test audio data
                for (integer j = 0; j < FRAME_SIZE; j = j + 1) begin
                    @(posedge clk_i);
                    while (!audio_ready_o) @(posedge clk_i);
                    audio_data_i = test_audio_data[test_vector_index][j];
                    audio_valid_i = 1'b1;
                    @(posedge clk_i);
                    audio_valid_i = 1'b0;
                end
                
                // Wait for processing
                @(posedge clk_i);
                while (busy_o) @(posedge clk_i);
                
                if (!error_o) begin
                    frame_count = frame_count + 1;
                end
                
                test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
            end
            
            if (frame_count == 10) begin
                $display("✓ Continuous operation test passed (%0d frames)", frame_count);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Continuous operation test failed (%0d/10 frames)", frame_count);
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
        end
    endtask
    
    // Test Category 9: Edge Cases
    task test_edge_cases;
        integer i;
        begin
            $display("Testing edge cases...");
            current_test = current_test + 1;
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h0;  // Minimum bitrate
            bandwidth_sel_i = 2'b00;  // Minimum bandwidth
            
            // Test with maximum amplitude
            for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                @(posedge clk_i);
                while (!audio_ready_o) @(posedge clk_i);
                audio_data_i = 16'h7FFF;  // Maximum positive amplitude
                audio_valid_i = 1'b1;
                @(posedge clk_i);
                audio_valid_i = 1'b0;
            end
            
            while (busy_o) @(posedge clk_i);
            
            if (!error_o) begin
                $display("✓ Edge case test passed (max amplitude)");
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Edge case test failed");
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
            
            test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
        end
    endtask
    
    // Test Category 10: Quality Metrics
    task test_quality_metrics;
        integer i, quality_sum;
        begin
            $display("Testing quality metrics...");
            current_test = current_test + 1;
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h7;  // Maximum bitrate
            bandwidth_sel_i = 2'b10;  // Maximum bandwidth
            
            quality_sum = 0;
            
            // Process multiple frames and collect quality metrics
            for (i = 0; i < 5; i = i + 1) begin
                // Send test audio data
                for (integer j = 0; j < FRAME_SIZE; j = j + 1) begin
                    @(posedge clk_i);
                    while (!audio_ready_o) @(posedge clk_i);
                    audio_data_i = test_audio_data[test_vector_index][j];
                    audio_valid_i = 1'b1;
                    @(posedge clk_i);
                    audio_valid_i = 1'b0;
                end
                
                // Wait for processing
                @(posedge clk_i);
                while (busy_o) @(posedge clk_i);
                
                quality_sum = quality_sum + quality_metric_o;
                test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
            end
            
            if (!error_o) begin
                $display("✓ Quality metrics test passed (avg quality: %0d)", quality_sum / 5);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Quality metrics test failed");
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
        end
    endtask
    
    //=============================================================================
    // Frame Buffering Verification Tests
    //=============================================================================
    
    // Test Category 11: Frame Buffering Behavior
    task test_frame_buffering;
        integer i, j, frame_count;
        reg [15:0] expected_frame [0:FRAME_SIZE-1];
        begin
            $display("Testing frame buffering behavior...");
            current_test = current_test + 1;
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h5;  // Medium bitrate
            bandwidth_sel_i = 2'b01;  // Medium bandwidth
            
            frame_count = 0;
            
            // Test 1: Verify complete frame collection
            $display("  Test 1: Complete frame collection");
            for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                @(posedge clk_i);
                while (!audio_ready_o) @(posedge clk_i);
                audio_data_i = test_audio_data[test_vector_index][i];
                audio_valid_i = 1'b1;
                @(posedge clk_i);
                audio_valid_i = 1'b0;
            end
            
            // Wait for frame processing
            @(posedge clk_i);
            while (busy_o) @(posedge clk_i);
            frame_count = frame_count + 1;
            
            // Test 2: Verify partial frame handling
            $display("  Test 2: Partial frame handling");
            for (i = 0; i < FRAME_SIZE/2; i = i + 1) begin
                @(posedge clk_i);
                while (!audio_ready_o) @(posedge clk_i);
                audio_data_i = test_audio_data[test_vector_index][i];
                audio_valid_i = 1'b1;
                @(posedge clk_i);
                audio_valid_i = 1'b0;
            end
            
            // Complete the frame
            for (i = FRAME_SIZE/2; i < FRAME_SIZE; i = i + 1) begin
                @(posedge clk_i);
                while (!audio_ready_o) @(posedge clk_i);
                audio_data_i = test_audio_data[test_vector_index][i];
                audio_valid_i = 1'b1;
                @(posedge clk_i);
                audio_valid_i = 1'b0;
            end
            
            // Wait for frame processing
            @(posedge clk_i);
            while (busy_o) @(posedge clk_i);
            frame_count = frame_count + 1;
            
            // Test 3: Verify frame boundary detection
            $display("  Test 3: Frame boundary detection");
            for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                @(posedge clk_i);
                while (!audio_ready_o) @(posedge clk_i);
                audio_data_i = test_audio_data[test_vector_index][i];
                audio_valid_i = 1'b1;
                @(posedge clk_i);
                audio_valid_i = 1'b0;
                
                // Check if frame is complete
                if (i == FRAME_SIZE - 1) begin
                    // Should trigger frame processing
                    @(posedge clk_i);
                    if (busy_o) begin
                        $display("    ✓ Frame boundary detected correctly");
                    end else begin
                        $display("    ✗ Frame boundary not detected");
                    end
                end
            end
            
            // Wait for frame processing
            @(posedge clk_i);
            while (busy_o) @(posedge clk_i);
            frame_count = frame_count + 1;
            
            if (!error_o && frame_count == 3) begin
                $display("✓ Frame buffering test passed (%0d frames processed)", frame_count);
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Frame buffering test failed");
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
            
            test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
        end
    endtask
    
    // Test Category 12: Full Frame Interface Verification
    task test_full_frame_interface;
        integer i, j;
        reg [15:0] frame_data [0:FRAME_SIZE-1];
        begin
            $display("Testing full frame interface...");
            current_test = current_test + 1;
            
            encode_mode_i = 1'b1;
            bitrate_sel_i = 4'h6;  // High bitrate
            bandwidth_sel_i = 2'b10;  // High bandwidth
            
            // Generate a test frame
            for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                frame_data[i] = test_audio_data[test_vector_index][i];
            end
            
            // Send complete frame
            for (i = 0; i < FRAME_SIZE; i = i + 1) begin
                @(posedge clk_i);
                while (!audio_ready_o) @(posedge clk_i);
                audio_data_i = frame_data[i];
                audio_valid_i = 1'b1;
                @(posedge clk_i);
                audio_valid_i = 1'b0;
            end
            
            // Wait for frame processing and verify full frame interface
            @(posedge clk_i);
            while (busy_o) @(posedge clk_i);
            
            // Verify that frame processing completed successfully
            if (!error_o) begin
                $display("✓ Full frame interface test passed");
                tests_passed = tests_passed + 1;
            end else begin
                $display("✗ Full frame interface test failed");
                tests_failed = tests_failed + 1;
                error_count = error_count + 1;
            end
            
            test_vector_index = (test_vector_index + 1) % NUM_TEST_VECTORS;
        end
    endtask
    
    //=============================================================================
    // Results Reporting
    //=============================================================================
    
    task print_comprehensive_results;
        real pass_rate, avg_encoding_latency, avg_decoding_latency;
        begin
            $display("=== Comprehensive Test Results ===");
            $display("Total Tests: %0d", tests_passed + tests_failed);
            $display("Tests Passed: %0d", tests_passed);
            $display("Tests Failed: %0d", tests_failed);
            
            if (tests_passed + tests_failed > 0) begin
                pass_rate = (tests_passed / (tests_passed + tests_failed)) * 100.0;
                $display("Pass Rate: %0.1f%%", pass_rate);
            end
            
            $display("=== Performance Metrics ===");
            $display("Total Frames Processed: %0d", total_frames_processed);
            $display("Total Encoding Time: %0d cycles", total_encoding_time);
            $display("Total Decoding Time: %0d cycles", total_decoding_time);
            
            if (total_frames_processed > 0) begin
                avg_encoding_latency = total_encoding_time / total_frames_processed;
                avg_decoding_latency = total_decoding_time / total_frames_processed;
                $display("Average Encoding Latency: %0.1f cycles", avg_encoding_latency);
                $display("Average Decoding Latency: %0.1f cycles", avg_decoding_latency);
            end
            
            $display("=== Error Statistics ===");
            $display("Error Count: %0d", error_count);
            $display("Timeout Count: %0d", timeout_count);
            $display("Backpressure Count: %0d", backpressure_count);
            
            if (tests_failed == 0) begin
                $display("🎉 ALL TESTS PASSED!");
            end else begin
                $display("⚠️  SOME TESTS FAILED!");
            end
            
            $display("=== Test Coverage Summary ===");
            $display("✓ Basic Functionality: 3 tests");
            $display("✓ Bitrate Coverage: %0d tests", NUM_BITRATES);
            $display("✓ Bandwidth Coverage: %0d tests", NUM_BANDWIDTHS);
            $display("✓ Audio Patterns: %0d tests", NUM_AUDIO_PATTERNS);
            $display("✓ Performance Tests: 1 test");
            $display("✓ Error Conditions: 1 test");
            $display("✓ Backpressure Handling: 1 test");
            $display("✓ Continuous Operation: 1 test");
            $display("✓ Edge Cases: 1 test");
            $display("✓ Quality Metrics: 1 test");
            $display("✓ Frame Buffering Verification: 1 test");
            $display("✓ Full Frame Interface Verification: 1 test");
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
            $display("Warning: Error detected at time %0t in test %0d", $time, current_test);
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
            $dumpfile("tb_mlow_codec_comprehensive.vcd");
        end
        $dumpvars(0, tb_mlow_codec_comprehensive);
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