# PRD.md — AuraSound (Procedural Ambient DSP Engine)

> Product Requirements Document for AuraSound: A 100% algorithmic ambient sound synthesizer that generates non-looping, infinite acoustic environments purely through mathematical DSP equations without any pre-recorded audio files.

---

## 🎯 1. Objective & Problem Statement

### The Problem
Ambient sound apps (for focus, sleep, or coding) suffer from major shortcomings:
- They loop repetitive 30–60 second `.mp3` samples that human brains quickly recognize as artificial.
- They consume hundreds of megabytes or gigabytes of storage for pre-recorded audio files.
- Static recordings cannot dynamically react to the user's environment, focus modes, or device context.

### The Solution
**AuraSound** generates rich, lifelike soundscapes (Rain, Distant Thunder, Campfire, Forest Wind, and Binaural Focus Waves) purely through real-time mathematical digital signal processing (DSP):
- **Zero Audio Assets**: App binary size is $< 1.5\text{MB}$.
- **Infinite Non-Looping Variety**: Every raindrop, crackle, and thunder roll is synthesized procedurally via stochastic differential equations, Poisson distributions, and resonant filters.
- **Ultra-Low Resource Profile**: Runs natively on Apple Silicon using `AVAudioEngine` and `Accelerate.vDSP` consuming $< 1.0\%$ CPU.

---

## 📐 2. Mathematical DSP Formulations

### 2.1 Procedural Rain Synthesis
Rain sound consists of two distinct components: a background atmospheric hiss (filtered pink noise) and individual droplet impacts (transient impulses).

1. **Pink Noise Generator (Paul Kellet's 3-Pole Filter)**:
   White noise $w[n] \sim \mathcal{U}(-1, 1)$ is processed through a multi-pole IIR filter providing a $-3\text{dB/octave}$ roll-off:
   $$b_0 = 0.99886 \cdot b_0 + w[n] \cdot 0.0555179$$
   $$b_1 = 0.99332 \cdot b_1 + w[n] \cdot 0.0750759$$
   $$b_2 = 0.96900 \cdot b_2 + w[n] \cdot 0.1538520$$
   $$b_3 = 0.86650 \cdot b_3 + w[n] \cdot 0.3104856$$
   $$\text{pink}[n] = b_0 + b_1 + b_2 + b_3 + w[n] \cdot 0.5362$$

2. **Poisson Droplet Impulses**:
   Individual droplet impacts are modeled as a Poisson point process with arrival rate $\lambda$ (droplets/sec):
   $$P(k\text{ impacts in time }\Delta t) = \frac{(\lambda \Delta t)^k e^{-\lambda \Delta t}}{k!}$$
   Each droplet triggers an exponentially damped high-Q resonant biquad bandpass filter:
   $$h_{\text{drop}}(t) = A_k \cdot e^{-t / \tau} \cdot \sin(2\pi f_k t)$$
   where $f_k \sim \mathcal{U}(1200\text{Hz}, 4800\text{Hz})$ and damping factor $\tau \approx 2.5\text{ms}$.

---

### 2.2 Procedural Thunder Synthesis
Thunder is synthesized using low-frequency Brownian (red) noise passing through a non-linear dynamic waveshaper:

1. **Brownian Integration**:
   $$b[n] = 0.98 \cdot b[n-1] + 0.02 \cdot w[n]$$
   Filtered through a 4th-order Butterworth lowpass filter with cutoff $f_c = 85\text{Hz}$.

2. **ADSR Spatial Waveshaping**:
   Thunder events trigger an asymmetric envelope $E(t)$ with fast attack ($150\text{ms}$), peak saturation, and a long rumbling decay ($6\text{s} - 12\text{s}$):
   $$\text{thunder}[n] = \tanh\left( G \cdot E[n] \cdot b[n] \right)$$
   where the hyperbolic tangent ($\tanh$) provides smooth analog tube saturation and prevents digital harsh clipping.

---

### 2.3 Procedural Campfire Crackle
Wood combustion creates random thermal popping and steady ash hissing:
- **Hiss Layer**: Filtered pink noise passing through a bandpass filter ($2.5\text{kHz} - 7.5\text{kHz}$).
- **Micro-Pops**: Asymmetric impulse bursts triggered when a uniform random variable exceeds threshold $\theta$:
  $$\text{trigger}[n] = \begin{cases} \text{sgn}(w[n]) \cdot |w[n]|^3 & \text{if } |w[n]| > \theta \\ 0 & \text{otherwise} \end{cases}$$
  Routed through high-Q resonant filters ($Q \approx 30$) simulating the resonant cavity of splitting wood.

---

### 2.4 Mathematical Binaural Beat Oscillators
Generates pure stereo phase-locked sine waves to stimulate specific neural oscillations through frequency differentials:
$$y_L(t) = A \cdot \sin\left(2\pi \left(f_c - \frac{\Delta f}{2}\right) t\right)$$
$$y_R(t) = A \cdot \sin\left(2\pi \left(f_c + \frac{\Delta f}{2}\right) t\right)$$

| Mode | Carrier ($f_c$) | Differential ($\Delta f$) | Brainwave State |
| :--- | :--- | :--- | :--- |
| **Gamma** | $240\text{ Hz}$ | $40.0\text{ Hz}$ | Complex problem solving & hyper-focus |
| **Beta** | $220\text{ Hz}$ | $18.0\text{ Hz}$ | Active coding and high alertness |
| **Alpha** | $200\text{ Hz}$ | $10.0\text{ Hz}$ | Relaxed flow state and creative coding |
| **Theta** | $180\text{ Hz}$ | $6.0\text{ Hz}$ | Deep ideation and contemplative rest |

---

## 🎚️ 3. Sound Control Parameters & Ranges

| Sound Parameter | Slider Range | Default | DSP Modulation Target |
| :--- | :--- | :--- | :--- |
| **Rain Intensity** | $0\% - 100\%$ | $65\%$ | Poisson droplet rate $\lambda \in [10, 800]\text{ drops/s}$ |
| **Surface Resonance** | Glass $\leftrightarrow$ Roof | Roof | Bandpass center frequency $f_0 \in [1.8\text{kHz}, 4.2\text{kHz}]$ |
| **Thunder Frequency** | Off $\leftrightarrow$ High | Low | Random event probability $P_{\text{thunder}} \in [0.001, 0.05]$ |
| **Campfire Warmth** | $0\% - 100\%$ | $40\%$ | Low-end rumble gain & crackle density |
| **Wind Gusts** | $0\% - 100\%$ | $30\%$ | LFO depth modulating bandpass sweep |
| **Binaural Volume** | $0\% - 100\%$ | $25\%$ | Sine oscillator amplitude ceiling |

---

## 🚫 4. Non-Goals
- No sample loading, audio file decoders, or streaming audio URLs.
- No network requests or online telemetry.
