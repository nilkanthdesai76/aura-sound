# AGENTS.md — AuraSound Operational Manual

> Ground-truth invariants, build/test commands, and rules for AI coding assistants working in `aura-sound`.

---

## 🧭 1. Project Overview
- **Project Name**: `aura-sound`
- **Core Purpose**: 100% algorithmic, zero-sample ambient sound synthesizer for macOS.
- **Primary Tech Stack**: Swift 6, CoreAudio, `AVAudioEngine`, `Accelerate.vDSP`, SwiftUI.
- **Deployment Targets**: macOS 14.0+ (Sonoma, Sequoia).

---

## ⚡ 2. Verified Execution Commands

```bash
# Build project using Swift Package Manager
swift build

# Run unit tests
swift test

# Run single targeted test
swift test --filter DSPMathTests

# Build with strict warnings as errors
swift build -Xswiftc -warnings-as-errors

# Run macOS app target (when building with xcodebuild)
xcodebuild -scheme AuraSound -configuration Debug build
```

---

## 🛡️ 3. Critical Invariants

1. **Audio Real-Time Thread Safety**:
   - Never take locks, access `@MainActor` state, or allocate reference types inside `AVAudioSourceNode` render blocks.
   - Use atomic types (`ManagedAtomic`) or lock-free ring buffers for thread communication.
2. **Strict Swift Concurrency**:
   - All shared state between SwiftUI and audio lifecycle must conform to `Sendable`.
3. **Zero Audio Asset Policy**:
   - Do NOT add `.wav`, `.mp3`, or `.aac` sample files to the project. All sounds must remain procedurally synthesized through code.
