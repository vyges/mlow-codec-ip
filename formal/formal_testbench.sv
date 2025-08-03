//=============================================================================
// Formal Testbench - MLow Codec
//=============================================================================
// Description: Simple testbench for formal verification with Verilator
//              Includes verification checks and provides main function
//
// Author:      Vyges Team
// Date:        2025-08-03T03:00:00Z
// Version:     1.0.0
// License:     Apache-2.0
//=============================================================================

`timescale 1ns/1ps

module formal_testbench;

    //=============================================================================
    // Parameters
    //=============================================================================
    
    parameter CLK_PERIOD = 20;  // 50MHz clock
    parameter FRAME_SIZE = 16;  // 16-sample frames for quick verification
    parameter SAMPLE_RATE = 48000;
    parameter MAX_BITRATE = 32000;
    parameter LPC_ORDER = 16;
    parameter SUBBAND_COUNT = 2;
    
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
    
    // Frame Interface
    wire [15:0] frame_data_o;
    wire [15:0] frame_data_bus_o [0:FRAME_SIZE-1];
    wire        frame_bus_valid_o;
    reg         frame_bus_ready_i;
    wire        frame_valid_o;
    reg         frame_ready_i;
    
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
    
    // Note: encoder/decoder status signals are internal to mlow_codec module
    
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
    // Verification Checks Instantiation
    //=============================================================================
    
    verification_checks verif_checks (
        .clk_i(clk_i),
        .reset_n_i(reset_n_i),
        .audio_data_i(audio_data_i),
        .audio_valid_i(audio_valid_i),
        .audio_ready_o(audio_ready_o),
        .audio_data_o(audio_data_o),
        .audio_valid_o(audio_valid_o),
        .audio_ready_i(audio_ready_i),
        .frame_data_o(frame_data_o),
        .frame_data_bus_o(frame_data_bus_o),
        .frame_bus_valid_o(frame_bus_valid_o),
        .frame_bus_ready_i(frame_bus_ready_i),
        .frame_valid_o(frame_valid_o),
        .frame_ready_i(frame_ready_i),
        .packet_data_io(packet_data_io),
        .packet_valid_o(packet_valid_o),
        .packet_ready_i(packet_ready_i),
        .packet_start_o(packet_start_o),
        .packet_end_o(packet_end_o),
        .busy_o(busy_o),
        .error_o(error_o),
        .quality_metric_o(quality_metric_o)
        // Note: encoder/decoder status signals are internal to mlow_codec
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
        // Initialize signals
        reset_n_i = 0;
        audio_data_i = 16'h0000;
        audio_valid_i = 1'b0;
        audio_ready_i = 1'b1;
        frame_bus_ready_i = 1'b1;
        frame_ready_i = 1'b1;
        packet_ready_i = 1'b1;
        encode_mode_i = 1'b1;
        bitrate_sel_i = 4'h5;
        bandwidth_sel_i = 2'b01;
        
        // Release reset after a few cycles
        #(CLK_PERIOD * 5);
        reset_n_i = 1;
        
        // Simple test stimulus
        #(CLK_PERIOD * 10);
        
        // Send some audio data
        for (integer i = 0; i < FRAME_SIZE; i = i + 1) begin
            @(posedge clk_i);
            audio_data_i = 16'h1234 + i;
            audio_valid_i = 1'b1;
            @(posedge clk_i);
            audio_valid_i = 1'b0;
        end
        
        // Wait for processing
        #(CLK_PERIOD * 50);
        
        // Send another frame
        for (integer i = 0; i < FRAME_SIZE; i = i + 1) begin
            @(posedge clk_i);
            audio_data_i = 16'h5678 + i;
            audio_valid_i = 1'b1;
            @(posedge clk_i);
            audio_valid_i = 1'b0;
        end
        
        // Wait for completion
        #(CLK_PERIOD * 100);
        
        $display("Formal verification test completed");
        $finish;
    end
    
    //=============================================================================
    // Waveform Dumping
    //=============================================================================
    
    initial begin
        $dumpfile("formal_testbench.vcd");
        $dumpvars(0, formal_testbench);
    end

endmodule : formal_testbench 