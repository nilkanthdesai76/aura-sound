# TESTING.md — AuraSound Test Strategy

> Verification protocols for mathematical audio signal generation and DSP filters.

---

## 🧪 1. Testing Strategy

1. **Noise Uniformity & Distribution Tests**:
   - Validates that pseudo-random generators produce flat white noise, $-3\text{dB/octave}$ pink noise, and $-6\text{dB/octave}$ brownian noise within $\pm 0.5\text{dB}$ statistical tolerance.
2. **Filter Stability Tests**:
   - Feeds unit impulse signals to `BiquadFilter` across frequency extremes ($20\text{Hz}$ to $20\text{kHz}$) to guarantee stability and prevent NaN/Infinity blowups.
3. **Limiter Ceiling Tests**:
   - Injects intentionally saturated signals ($+12\text{dBFS}$) and verifies that output peaks never exceed $1.0$ (0 dBFS).
4. **Lifecycle Tests**:
   - Repeatedly starts, pauses, and tears down `AudioEngineController` to ensure zero memory leaks or dangling CoreAudio sessions.

---

## ⚡ 2. Execution Commands

```bash
# Run full suite
swift test

# Run filter tests specifically
swift test --filter BiquadFilterTests
```
