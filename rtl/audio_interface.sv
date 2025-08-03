//=============================================================================
// Audio Interface - Icarus Verilog Compatible Version
//=============================================================================
// Description: Audio interface module compatible with Icarus Verilog
//              Handles frame buffering and audio data flow for MLow codec
//
// Features:
// - Frame-based audio buffering with configurable frame size
// - Handshake-based audio interface (valid/ready protocol)
// - State machine for frame collection and output
// - True array-based frame buffers for full frame support
//
// TODO: Implement full frame interface for parallel processing
// TODO: Add frame-level handshaking for better flow control
//
// Author:      Vyges Team
// Date:        2025-08-02T16:08:15Z
// Version:     1.0.0
// License:     Apache-2.0
//=============================================================================

module audio_interface #(
    parameter int SAMPLE_RATE = 48000,
    parameter int FRAME_SIZE = 480
) (
    // Clock and Reset
    input  logic        clk_i,
    input  logic        reset_n_i,
    
    // External audio interface
    input  logic [15:0] audio_data_i,
    input  logic        audio_valid_i,
    output logic        audio_ready_o,
    output logic [15:0] audio_data_o,
    output logic        audio_valid_o,
    input  logic        audio_ready_i,
    
    // Internal frame interface (full frame support)
    output logic [15:0] frame_data_o,                    // Current sample (backward compatibility)
    output logic [FRAME_SIZE-1:0] frame_data_valid_o,    // Valid bits for each sample
    output logic        frame_valid_o,                   // Frame complete indicator
    input  logic        frame_ready_i,                   // Frame ready handshake
    
    // Full frame interface (new)
    output logic [FRAME_SIZE*16-1:0] frame_data_bus_o, // Full frame data packed array
    output logic        frame_bus_valid_o,                  // Full frame valid
    input  logic        frame_bus_ready_i                   // Full frame ready handshake
);

    //=============================================================================
    // Internal Signals
    //=============================================================================
    
    // Frame buffer (packed array for synthesis compatibility)
    logic [FRAME_SIZE*16-1:0] frame_buffer;
    logic [$clog2(FRAME_SIZE):0] frame_count;
    logic frame_full;
    logic frame_empty;
    
    // Output buffer (packed array for synthesis compatibility)
    logic [FRAME_SIZE*16-1:0] output_buffer;
    logic [$clog2(FRAME_SIZE):0] output_count;
    logic output_full;
    logic output_empty;
    
    // State machine
    typedef enum logic [2:0] {
        IDLE,
        COLLECTING_FRAME,
        FRAME_READY,
        OUTPUTTING_FRAME,
        WAITING_OUTPUT
    } state_t;
    
    state_t current_state, next_state;
    
    //=============================================================================
    // Frame Buffer Control
    //=============================================================================
    
    assign frame_full = (frame_count == FRAME_SIZE);
    assign frame_empty = (frame_count == 0);
    assign output_full = (output_count == FRAME_SIZE);
    assign output_empty = (output_count == 0);
    
    //=============================================================================
    // Input Frame Collection
    //=============================================================================
    
    always_ff @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            frame_count <= 0;
            // Initialize frame buffer array
            for (int i = 0; i < FRAME_SIZE; i++) begin
                frame_buffer[i*16 +: 16] <= 16'h0000;
            end
        end else if (audio_valid_i && audio_ready_o && !frame_full) begin
            // Store sample in frame buffer array
            frame_buffer[frame_count*16 +: 16] <= audio_data_i;
            frame_count <= frame_count + 1;
        end else if (frame_valid_o && frame_ready_i) begin
            frame_count <= 0;
        end
    end
    
    //=============================================================================
    // Output Frame Generation
    //=============================================================================
    
    always_ff @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            output_count <= 0;
            // Initialize output buffer array
            for (int i = 0; i < FRAME_SIZE; i++) begin
                output_buffer[i*16 +: 16] <= 16'h0000;
            end
        end else if (frame_valid_o && frame_ready_i) begin
            // Copy entire frame data to output buffer array
            for (int i = 0; i < FRAME_SIZE; i++) begin
                output_buffer[i*16 +: 16] <= frame_buffer[i*16 +: 16];
            end
            output_count <= FRAME_SIZE;
        end else if (audio_valid_o && audio_ready_i && !output_empty) begin
            output_count <= output_count - 1;
        end
    end
    
    //=============================================================================
    // Output Assignments
    //=============================================================================
    
    // Frame data output (backward compatibility - outputs first sample)
    assign frame_data_o = frame_buffer[0*16 +: 16];
    assign frame_data_valid_o = (frame_count > 0) ? {FRAME_SIZE{1'b1}} : {FRAME_SIZE{1'b0}};
    
    // Full frame interface (new implementation)
    always_comb begin
        for (int i = 0; i < FRAME_SIZE; i++) begin
            frame_data_bus_o[i*16 +: 16] = frame_buffer[i*16 +: 16];
        end
    end
    assign frame_bus_valid_o = frame_full;
    
    //=============================================================================
    // State Machine
    //=============================================================================
    
    always_ff @(posedge clk_i or negedge reset_n_i) begin
        if (!reset_n_i) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (!frame_empty) begin
                    next_state = COLLECTING_FRAME;
                end
            end
            
            COLLECTING_FRAME: begin
                if (frame_full) begin
                    next_state = FRAME_READY;
                end
            end
            
            FRAME_READY: begin
                if (frame_ready_i) begin
                    next_state = OUTPUTTING_FRAME;
                end
            end
            
            OUTPUTTING_FRAME: begin
                if (output_empty) begin
                    next_state = WAITING_OUTPUT;
                end
            end
            
            WAITING_OUTPUT: begin
                if (!frame_empty) begin
                    next_state = COLLECTING_FRAME;
                end else begin
                    next_state = IDLE;
                end
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
    //=============================================================================
    // Output Assignments
    //=============================================================================
    
    // Frame interface
    assign frame_valid_o = frame_full;
    
    // Audio output interface
    assign audio_data_o = output_buffer[(output_count - 1)*16 +: 16];
    assign audio_valid_o = !output_empty && (current_state == OUTPUTTING_FRAME);
    assign audio_ready_o = !frame_full;
    
endmodule : audio_interface 