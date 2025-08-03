//=============================================================================
// MLow Codec - Icarus Verilog Compatible Version
//=============================================================================
// Description: MLow audio codec implementation compatible with Icarus Verilog
//              and other open-source simulators
//
// Author:      Vyges Team
// Date:        2025-08-02T16:08:15Z
// Version:     1.0.0
// License:     Apache-2.0
//=============================================================================

module mlow_codec #(
    parameter int SAMPLE_RATE = 48000,
    parameter int FRAME_SIZE = 480,
    parameter int MAX_BITRATE = 32000,
    parameter int LPC_ORDER = 16,
    parameter int SUBBAND_COUNT = 2
) (
    // Clock and Reset
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // Audio Interface
    input  logic [15:0] audio_data_i,
    input  logic        audio_valid_i,
    output logic        audio_ready_o,
    output logic [15:0] audio_data_o,
    output logic        audio_valid_o,
    input  logic        audio_ready_i,
    
    // Control Interface
    input  logic        encode_mode_i,
    input  logic [3:0]  bitrate_sel_i,
    input  logic [1:0]  bandwidth_sel_i,
    
    // Packet Interface
    inout  logic [7:0]  packet_data_io,
    output logic        packet_valid_o,
    input  logic        packet_ready_i,
    output logic        packet_start_o,
    output logic        packet_end_o,
    
    // Status Interface
    output logic        busy_o,
    output logic        error_o,
    output logic [7:0]  quality_metric_o
);

    //=============================================================================
    // Internal Signals
    //=============================================================================
    
    // Bitrate configuration table
    logic [15:0] bitrate_config [8];
    logic [15:0] current_bitrate;
    logic [1:0]  current_bandwidth;
    logic        encode_active;
    
    // Audio interface signals (internal)
    logic [15:0] int_frame_data;
    logic [FRAME_SIZE-1:0] int_frame_data_valid;
    logic        int_frame_valid;
    logic        int_frame_ready;
    logic [15:0] int_decoded_data;
    logic        int_decoded_valid;
    logic        int_decoded_ready;
    
    // Encoder/Decoder signals (internal)
    logic        int_encoded_valid;
    logic        int_encoded_ready;
    logic [15:0] int_range_decode_data;
    logic        int_range_decode_valid;
    logic        int_range_decode_ready;
    
    // Status signals
    logic        encoder_busy_o;
    logic        decoder_busy_o;
    logic        encoder_error_o;
    logic        decoder_error_o;
    logic [7:0]  encoder_quality_o;
    logic [7:0]  decoder_quality_o;
    
    // Packet framer signals
    logic        framer_busy_o;
    logic        framer_error_o;
    logic [15:0] framer_packet_count_o;
    
    // Internal frame data buses (packed arrays for synthesis compatibility)
    logic [FRAME_SIZE*16-1:0] int_frame_data_bus;
    logic [FRAME_SIZE*16-1:0] int_decoded_data_bus;
    logic [FRAME_SIZE*16-1:0] int_encoded_data;
    
    //=============================================================================
    // Bitrate Configuration
    //=============================================================================
    
    initial begin
        bitrate_config[0] = 16'd6000;   // 6 kbps
        bitrate_config[1] = 16'd8000;   // 8 kbps
        bitrate_config[2] = 16'd12000;  // 12 kbps
        bitrate_config[3] = 16'd16000;  // 16 kbps
        bitrate_config[4] = 16'd20000;  // 20 kbps
        bitrate_config[5] = 16'd24000;  // 24 kbps
        bitrate_config[6] = 16'd28000;  // 28 kbps
        bitrate_config[7] = 16'd32000;  // 32 kbps
    end
    
    //=============================================================================
    // Control Logic
    //=============================================================================
    
    always_ff @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            current_bitrate <= 16'd16000;
            current_bandwidth <= 2'b01;
            encode_active <= 1'b0;
        end else begin
            current_bitrate <= bitrate_config[bitrate_sel_i];
            current_bandwidth <= bandwidth_sel_i;
            encode_active <= encode_mode_i;
        end
    end
    
    //=============================================================================
    // Status Logic
    //=============================================================================
    
    assign busy_o = encoder_busy_o | decoder_busy_o;
    assign error_o = encoder_error_o | decoder_error_o;
    assign quality_metric_o = 8'd85; // Placeholder quality metric
    
    //=============================================================================
    // Audio Interface Module
    //=============================================================================
    
    audio_interface #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .FRAME_SIZE(FRAME_SIZE)
    ) audio_if (
        .clk_i(clk_i),
        .reset_n_i(reset_n_i),
        
        // External audio interface
        .audio_data_i(audio_data_i),
        .audio_valid_i(audio_valid_i),
        .audio_ready_o(audio_ready_o),
        .audio_data_o(audio_data_o),
        .audio_valid_o(audio_valid_o),
        .audio_ready_i(audio_ready_i),
        
        // Internal frame interface
        .frame_data_o(int_frame_data),
        .frame_data_valid_o(int_frame_data_valid),
        .frame_valid_o(int_frame_valid),
        .frame_ready_i(int_frame_ready),
        
        // Full frame interface (new) - TODO: implement array connections
        .frame_data_bus_o(),  // TODO: connect array properly
        .frame_bus_valid_o(), // TODO: connect properly
        .frame_bus_ready_i(1'b1) // Always ready for now
    );
    
    //=============================================================================
    // Blackbox Module Instantiations
    //=============================================================================
    
    // MLow Encoder Instance
    mlow_encoder #(
        .FRAME_SIZE(FRAME_SIZE),
        .LPC_ORDER(LPC_ORDER),
        .SUBBAND_COUNT(SUBBAND_COUNT)
    ) encoder_inst (
        .clk_i(clk_i),
        .reset_n_i(reset_n_i),
        
        // Frame input interface
        .frame_data_i(int_frame_data_bus),
        .frame_valid_i(int_frame_valid),
        .frame_ready_o(int_frame_ready),
        
        // Encoded output interface
        .encoded_data_o(int_encoded_data),
        .encoded_valid_o(int_encoded_valid),
        .encoded_ready_i(int_encoded_ready),
        
        // Control interface
        .bitrate_i(current_bitrate),
        .bandwidth_i(current_bandwidth),
        
        // Status interface
        .busy_o(encoder_busy_o),
        .error_o(encoder_error_o),
        .quality_metric_o(encoder_quality_o)
    );
    
    // MLow Decoder Instance
    mlow_decoder #(
        .FRAME_SIZE(FRAME_SIZE),
        .LPC_ORDER(LPC_ORDER),
        .SUBBAND_COUNT(SUBBAND_COUNT)
    ) decoder_inst (
        .clk_i(clk_i),
        .reset_n_i(reset_n_i),
        
        // Encoded input interface
        .encoded_data_i(int_range_decode_data),
        .encoded_valid_i(int_range_decode_valid),
        .encoded_ready_o(int_range_decode_ready),
        
        // Decoded output interface
        .decoded_data_o(int_decoded_data_bus),
        .decoded_valid_o(int_decoded_valid),
        .decoded_ready_i(int_decoded_ready),
        
        // Control interface
        .bitrate_i(current_bitrate),
        .bandwidth_i(current_bandwidth),
        
        // Status interface
        .busy_o(decoder_busy_o),
        .error_o(decoder_error_o),
        .quality_metric_o(decoder_quality_o)
    );
    
    // Packet Framer Instance
    packet_framer #(
        .MAX_PACKET_SIZE(1024)
    ) framer_inst (
        .clk_i(clk_i),
        .reset_n_i(reset_n_i),
        
        // Data input interface
        .data_i(int_encoded_data[7:0]),
        .data_valid_i(int_encoded_valid),
        .data_ready_o(int_encoded_ready),
        
        // Packet output interface
        .packet_data_o(packet_data_io),
        .packet_valid_o(packet_valid_o),
        .packet_ready_i(packet_ready_i),
        .packet_start_o(packet_start_o),
        .packet_end_o(packet_end_o),
        
        // Control interface
        .flush_i(1'b0),
        .max_length_i(16'd1024),
        
        // Status interface
        .busy_o(framer_busy_o),
        .error_o(framer_error_o),
        .packet_count_o(framer_packet_count_o)
    );
    
    // Range codec placeholder (simplified pass-through)
    assign int_range_decode_data = int_encoded_data;
    assign int_range_decode_valid = int_encoded_valid;
    
endmodule : mlow_codec 