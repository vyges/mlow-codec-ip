# MLow Codec SoC — Future Direction Notes

**Created:** 2026-03-16
**Status:** Exploratory — not a near-term work item
**Context:** Captured from architecture discussion during edge-sensor-soc development

---

## 1. Concept

A purpose-built SoC pairing the Ibex RISC-V CPU with the mlow-codec-ip as a
hardware audio codec accelerator, targeting IoT voice and audio sensor applications.
Follows the same architecture pattern as edge-sensor-soc (Ibex + hardware accelerator
+ TL-UL crossbar, Sky130A via Caravel/MPW).

The combination is compelling because:

- **Ibex (RV32IMC)** handles framing, packetization, radio protocol stack, sensor
  fusion — a full CPU without commercial licensing costs
- **mlow hardware codec** encodes/decodes in deterministic microseconds at ~5mW,
  vs a software codec on the same CPU burning 10x more power
- **Sky130 open PDK** — no NDA, fully auditable silicon; important for medical and
  defense-adjacent applications
- **Caravel MPW** submission costs are minimal; risk is low to get real silicon

---

## 2. Target Applications

Ranked by near-term market traction:

| Application | Key Requirement | Notes |
| ----------- | --------------- | ----- |
| Hearing aids / hearables | ≤35ms latency (hard requirement), ultra-low power | Medical grade = high ASP, small volumes; regulatory path needed |
| Wildlife / environmental monitoring | Long battery life, LoRa uplink, audio event capture | Academic/NGO funding available; no regulatory burden |
| Drone voice command | Narrow RF band, latency critical | Growing hobbyist + industrial market |
| Industrial push-to-talk wearables | Replaces proprietary DECT/PMR chips | Large replacement market; standard UART/SPI integration |
| Medical remote auscultation | Quality at 6 kbps over cellular, HIPAA at edge | Strong regulatory moat once certified |

The core differentiator across all of these: **high-quality voice over constrained
bandwidth at low power**. mlow delivers 2x better POLQA MOS than Opus at 6 kbps —
the bitrate that fits LoRa, NB-IoT, and narrowband RF channels where Opus sounds poor.

---

## 3. Why Not Add the FFT IP?

For a voice/audio codec SoC, the FFT accelerator from edge-sensor-soc is not needed:

- mlow's split-band CELP architecture handles frequency-domain processing internally
- The FFT IP (1024-point, 4 kSPS) was designed for vibration/accelerometer data,
  not for audio analysis at 48 kHz

FFT would add value only if the SoC needs **acoustic event detection alongside
voice coding** (e.g., combined vibration + audio sensor), or if a future audio
analysis use case requires spectral fingerprinting. That would be a different product.

---

## 4. Tentative SoC Architecture

```text
                    ┌─────────────────────────────────────┐
                    │        MLow Audio SoC (50 MHz)       │
                    │                                      │
  UART_RX ─────────┤→ UART ──────┐                       │
  UART_TX ←─────────┤← UART      │                       │
  I2S/PDM ─────────┤→ Audio IF  │                       │
                    │             ↓                        │
                    │       TL-UL Crossbar                 │
                    │        ↑          ↑                  │
                    │    Ibex RV32MC  mlow codec           │
                    │    CPU core     (APB slave)          │
                    │    ROM 32KB     RAM 64KB             │
                    └─────────────────────────────────────┘
                                  ↓ Caravel
                         user_project_wrapper
```

Key differences from edge-sensor-soc:

- mlow-codec replaces FFT accelerator as the hardware accelerator
- Audio interface (I2S or PDM) replaces ADC/SPI sensor interface
- SRAM sizing TBD — mlow codec needs frame buffers (480 samples × 16-bit = 960 bytes
  per frame; encoder state likely needs 4–8 KB)
- No dedicated SRAM macros needed if codec state fits in the standard 64 KB RAM

---

## 5. Prerequisites Before Committing to Tapeout

The mlow-codec-ip is currently `maturity: prototype`. Before designing a full SoC
around it, the following should be completed:

1. **OpenLane hardening of mlow-codec macro standalone**
   - Run `flow/openlane/run_openlane_mlow.sh` to get real Sky130 gate count and WNS
   - The 28nm estimate of ~50K gates / 0.1mm² likely scales to 150–250K gates /
     0.4–0.8mm² on Sky130 130nm — still fits in Caravel's 10mm² budget but needs
     confirmation
   - Identify any timing closure issues early

2. **RTL functional validation at codec level**
   - Verify encode→decode round-trip produces expected POLQA MOS
   - Confirm 480-sample frame processing at 48 kHz meets 10ms real-time constraint
     at 50 MHz clock

3. **Bus interface wrapper**
   - mlow-codec currently has a custom audio streaming interface (audio_data_i,
     audio_valid_i, etc.) — needs an APB or TL-UL slave wrapper, same pattern as
     fft_ctrl_tlul in edge-sensor-soc

4. **Audio input peripheral**
   - An I2S or PDM microphone interface IP is needed for a complete SoC
   - Check vyges-ip catalog; otherwise hand-maintain a minimal I2S slave

---

## 6. Suggested Next Step (When Ready)

Run the existing OpenLane config on the mlow-codec macro to get a real Sky130 area
and timing number. That single data point determines whether the SoC architecture
above is feasible as-is or needs design adjustments (floorplan, SRAM sizing, clock).

```bash
# From mlow-codec-ip repo root, on OpenLane instance
bash flow/openlane/run_openlane_mlow.sh
```

Everything else (SoC generation from soc-spec.yaml, Caravel wrapper, firmware)
follows the same pattern already established in edge-sensor-soc.
