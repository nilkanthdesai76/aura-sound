# AuraSound 🌧️🔥🧠

> 100% Mathematical Procedural Ambient Sound Generator for macOS. Zero audio files. Infinite non-looping soundscapes.

[![Platform](https://img.shields.io/badge/Platform-macOS%2014.0%2B-blue.svg)](https://developer.apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Accelerate](https://img.shields.io/badge/Accelerate-vDSP-green.svg)](https://developer.apple.com/documentation/accelerate)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features

- 🌧️ **Procedural Rain & Thunder** — Synthesizes realistic rainfall, droplet surface resonance (glass/tin), and randomized rolling thunder without repeating audio loops.
- 🔥 **Campfire & Wind Dynamics** — Micro-spark thermal crackles and aerodynamic wind gusts powered by Poisson distributions and sweeping bandpass filters.
- 🧠 **Precision Binaural Beats** — Exact dual-channel phase-shifted carrier oscillators for Gamma (40 Hz), Beta (20 Hz), Alpha (10 Hz), and Theta (6 Hz) cognitive states.
- ⚡ **Zero Audio Assets ($< 1.5\text{MB}$)** — The entire application contains zero audio files. Every waveform is rendered via real-time mathematical DSP.
- 🔋 **Zero Thermal Footprint** — Consumes $< 1.0\%$ CPU on Apple Silicon M-series using `Accelerate.vDSP` vector SIMD optimizations.
- 🧭 **Menu Bar Companion** — Lives quietly in your macOS menu bar with global hotkey controls.

---

## ⚡ Quick Start

```bash
# Clone and build
git clone https://github.com/nilkanthdesai76/aura-sound.git
cd aura-sound

# Build & Run tests
swift test

# Build application
swift build -c release
```

---

## 📚 Documentation Pillars
- [PRD.md](PRD.md) — Product specifications and acoustic requirements
- [ARCHITECTURE.md](ARCHITECTURE.md) — DSP audio graph and pipeline taxonomy
- [AGENTS.md](AGENTS.md) — Operational instructions for AI coding agents
- [TESTING.md](TESTING.md) — Signal stability and filter test strategies
- [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) — Visual tokens and midnight studio UI
