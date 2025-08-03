# Waveform Examples: MLow Audio Codec IP

This document captures key waveform behaviors observed in simulation to verify correct functionality of the MLow audio codec IP.

---

## 1. Audio Interface Frame Buffering

**Scenario**: Audio samples are collected into frame buffer and full frame is output via frame bus interface.

```
| Time(ns) | clk | rst_n | audio_data_i | audio_valid_i | audio_ready_o | frame_bus_valid_o | frame_bus_ready_i | frame_data_bus_o[0] | frame_data_bus_o[15] | Notes |
| -------- | --- | ----- | ------------ | ------------- | ------------- | ----------------- | ----------------- | ------------------- | -------------------- | ----- |
| 0        | 0   | 0     | 16'h0000     | 0             | 0             | 0                 | 0                 | 16'h0000            | 16'h0000             | Reset active |
| 100      | 1   | 1     | 16'h1234     | 1             | 1             | 0                 | 1                 | 16'h0000            | 16'h0000             | Sample 0 |
| 200      | 1   | 1     | 16'h5678     | 1             | 1             | 0                 | 1                 | 16'h0000            | 16'h0000             | Sample 1 |
| ...      | ... | 1     | ...          | 1             | 1             | 0                 | 1                 | 16'h0000            | 16'h0000             | Samples 2-14 |
| 1600     | 1   | 1     | 16'h9ABC     | 1             | 1             | 1                 | 1                 | 16'h1234            | 16'h9ABC             | Frame complete |
| 1700     | 1   | 1     | 16'hDEF0     | 1             | 1             | 0                 | 1                 | 16'h0000            | 16'h0000             | Next frame start |
```

---

## 2. Frame Bus Handshake Protocol

**Scenario**: Complete frame transfer via frame bus interface with handshake signals.

```
| Time(ns) | clk | frame_bus_valid_o | frame_bus_ready_i | frame_data_bus_o[0] | frame_data_bus_o[15] | Notes |
| -------- | --- | ----------------- | ----------------- | ------------------- | -------------------- | ----- |
| 0        | 0   | 0                 | 1                 | 16'h0000            | 16'h0000             | Idle |
| 100      | 1   | 1                 | 1                 | 16'h1234            | 16'h9ABC             | Frame transfer |
| 200      | 1   | 1                 | 0                 | 16'h1234            | 16'h9ABC             | Backpressure |
| 300      | 1   | 1                 | 1                 | 16'h1234            | 16'h9ABC             | Transfer complete |
| 400      | 1   | 0                 | 1                 | 16'h0000            | 16'h0000             | Idle |
```

---

## 3. Encoding Mode Operation

**Scenario**: Audio data is encoded at 16 kbps with WideBand configuration.

```
| Time(ns) | clk | rst_n | encode_mode_i | bitrate_sel_i | bandwidth_sel_i | audio_valid_i | packet_valid_o | packet_data_io | busy_o | Notes |
| -------- | --- | ----- | ------------- | ------------- | --------------- | ------------- | -------------- | -------------- | ------ | ----- |
| 0        | 0   | 0     | 0             | 4'h0          | 2'b00           | 0             | 0              | 8'h00          | 0      | Reset |
| 100      | 1   | 1     | 1             | 4'h3          | 2'b01           | 0             | 0              | 8'h00          | 0      | Configure |
| 200      | 1   | 1     | 1             | 4'h3          | 2'b01           | 1             | 0              | 8'h00          | 1      | Start encoding |
| 300      | 1   | 1     | 1             | 4'h3          | 2'b01           | 1             | 0              | 8'h00          | 1      | Processing |
| 400      | 1   | 1     | 1             | 4'h3          | 2'b01           | 0             | 1              | 8'hA5          | 0      | Packet output |
```

---

## 4. Decoding Mode Operation

**Scenario**: Compressed packet data is decoded back to audio samples.

```
| Time(ns) | clk | rst_n | encode_mode_i | packet_valid_o | packet_data_io | audio_valid_o | audio_data_o | busy_o | Notes |
| -------- | --- | ----- | ------------- | -------------- | -------------- | ------------- | ------------ | ------ | ----- |
| 0        | 0   | 0     | 0             | 0              | 8'h00          | 0             | 16'h0000      | 0      | Reset |
| 100      | 1   | 1     | 0             | 0              | 8'h00          | 0             | 16'h0000      | 0      | Idle |
| 200      | 1   | 1     | 0             | 1              | 8'hA5          | 0             | 16'h0000      | 1      | Packet input |
| 300      | 1   | 1     | 0             | 0              | 8'h00          | 0             | 16'h0000      | 1      | Processing |
| 400      | 1   | 1     | 0             | 0              | 8'h00          | 1             | 16'h1234      | 0      | Audio output |
```

---

## 5. Frame Buffer Overflow Prevention

**Scenario**: Frame buffer overflow is prevented by backpressure mechanism.

```
| Time(ns) | clk | audio_valid_i | audio_ready_o | frame_bus_valid_o | frame_bus_ready_i | Notes |
| -------- | --- | ------------- | ------------- | ----------------- | ----------------- | ----- |
| 0        | 0   | 1             | 1             | 0                 | 1                 | Normal operation |
| 100      | 1   | 1             | 1             | 0                 | 1                 | Collecting samples |
| 200      | 1   | 1             | 1             | 0                 | 1                 | Frame nearly full |
| 300      | 1   | 1             | 0             | 0                 | 1                 | Backpressure active |
| 400      | 1   | 1             | 0             | 1                 | 0                 | Frame ready, downstream busy |
| 500      | 1   | 1             | 0             | 1                 | 1                 | Frame transfer |
| 600      | 1   | 1             | 1             | 0                 | 1                 | Resume collection |
```

---

## 6. Quality Metric Monitoring

**Scenario**: Quality metrics are monitored during encoding operation.

```
| Time(ns) | clk | encode_mode_i | busy_o | quality_metric_o | error_o | Notes |
| -------- | --- | ------------- | ------ | ---------------- | ------- | ----- |
| 0        | 0   | 0             | 0      | 8'h00            | 0       | Idle |
| 100      | 1   | 1             | 1      | 8'h00            | 0       | Start encoding |
| 200      | 1   | 1             | 1      | 8'h45            | 0       | Processing |
| 300      | 1   | 1             | 1      | 8'h67            | 0       | Quality update |
| 400      | 1   | 1             | 0      | 8'h78            | 0       | Encoding complete |
| 500      | 1   | 0             | 0      | 8'h78            | 0       | Idle |
```

---

## 7. Error Condition Handling

**Scenario**: Error conditions are detected and reported.

```
| Time(ns) | clk | rst_n | audio_valid_i | packet_valid_o | error_o | busy_o | Notes |
| -------- | --- | ----- | ------------- | -------------- | ------- | ------ | ----- |
| 0        | 0   | 0     | 0             | 0              | 0       | 0      | Reset |
| 100      | 1   | 1     | 1             | 0              | 0       | 1      | Normal operation |
| 200      | 1   | 1     | 1             | 0              | 0       | 1      | Processing |
| 300      | 1   | 1     | 1             | 0              | 1       | 0      | Error detected |
| 400      | 1   | 1     | 0             | 0              | 1       | 0      | Error state |
| 500      | 1   | 0     | 0             | 0              | 0       | 0      | Reset clears error |
```

---

## 8. 16-Sample Frame Processing

**Scenario**: Quick simulation with 16-sample frames for rapid testing.

```
| Time(ns) | clk | frame_count | frame_bus_valid_o | frame_data_bus_o[0] | frame_data_bus_o[15] | Notes |
| -------- | --- | ----------- | ----------------- | ------------------- | -------------------- | ----- |
| 0        | 0   | 0           | 0                 | 16'h0000            | 16'h0000             | Reset |
| 100      | 1   | 1           | 0                 | 16'h0000            | 16'h0000             | Sample 1 |
| 200      | 1   | 2           | 0                 | 16'h0000            | 16'h0000             | Sample 2 |
| ...      | ... | ...         | 0                 | 16'h0000            | 16'h0000             | Samples 3-15 |
| 1600     | 1   | 16          | 1                 | 16'h1234            | 16'h9ABC             | Frame complete |
| 1700     | 1   | 1           | 0                 | 16'h0000            | 16'h0000             | Next frame |
```

---

## 9. Blackbox Module Integration

**Scenario**: Blackbox modules (encoder, decoder, packet framer) are integrated and tested.

```
| Time(ns) | clk | encoder_busy_o | decoder_busy_o | framer_busy_o | packet_valid_o | Notes |
| -------- | --- | -------------- | -------------- | -------------- | -------------- | ----- |
| 0        | 0   | 0              | 0              | 0              | 0              | Reset |
| 100      | 1   | 1              | 0              | 0              | 0              | Encoder active |
| 200      | 1   | 1              | 0              | 1              | 0              | Encoder + framer |
| 300      | 1   | 0              | 0              | 1              | 1              | Packet output |
| 400      | 1   | 0              | 1              | 0              | 0              | Decoder active |
| 500      | 1   | 0              | 0              | 0              | 0              | Idle |
```

---

## 10. Formal Verification Coverage

**Scenario**: Formal verification checks monitor frame integrity and handshake protocols.

```
| Time(ns) | clk | frame_bus_valid_o | frame_bus_ready_i | frame_data_bus_o[0] | frame_data_bus_o[15] | Coverage Event |
| -------- | --- | ----------------- | ----------------- | ------------------- | -------------------- | -------------- |
| 0        | 0   | 0                 | 1                 | 16'h0000            | 16'h0000             | Idle state |
| 100      | 1   | 1                 | 1                 | 16'h1234            | 16'h9ABC             | Frame transfer |
| 200      | 1   | 1                 | 0                 | 16'h1234            | 16'h9ABC             | Backpressure |
| 300      | 1   | 1                 | 1                 | 16'h1234            | 16'h9ABC             | Transfer complete |
| 400      | 1   | 0                 | 1                 | 16'h0000            | 16'h0000             | Idle state |
```

---

## Notes

- All waveforms can be visualized in GTKWave, ModelSim, or open-source VCD viewers
- Use `make wave` to generate VCD files for waveform analysis
- Frame buffering waveforms show enhanced array-based storage behavior
- 16-sample frame processing enables quick simulation testing
- Formal verification waveforms demonstrate assertion-based checking
- Blackbox module integration shows placeholder implementation behavior

---

## Key Waveform Characteristics

### Frame Buffering
- **Array-based Storage**: Complete frame stored in `frame_buffer[0:FRAME_SIZE-1]`
- **Full Frame Bus**: Parallel access to all frame samples via `frame_data_bus_o[0:FRAME_SIZE-1]`
- **Handshake Protocol**: Dedicated `frame_bus_valid_o` and `frame_bus_ready_i` signals
- **Backward Compatibility**: `frame_data_o` maintains existing interface compatibility

### Quality Monitoring
- **Real-time Metrics**: Quality metrics updated during processing
- **Error Detection**: Error conditions detected and reported
- **Status Monitoring**: Busy signals indicate processing state

### Performance Verification
- **Latency Measurement**: End-to-end processing time verification
- **Throughput Analysis**: Continuous frame processing capability
- **Resource Utilization**: Busy signal patterns for resource monitoring

### Formal Verification
- **Frame Integrity**: Data consistency and validity checks
- **Handshake Protocols**: Valid/ready signal protocol verification
- **Error Handling**: Error condition monitoring and reporting

