import Foundation

/// High-throughput, allocation-free pseudo-random noise generator optimized for real-time audio threads.
public struct FastNoise: Sendable {
    private var state0: UInt64
    private var state1: UInt64
    
    // Kellet pink noise filter states
    private var b0: Float = 0.0
    private var b1: Float = 0.0
    private var b2: Float = 0.0
    private var b3: Float = 0.0
    
    // Brownian leaky integrator state
    private var brownState: Float = 0.0
    
    public init(seed: UInt64 = 0x8542D5207B4F4D5) {
        self.state0 = seed
        self.state1 = seed ^ 0x9E3779B97F4A7C15
    }
    
    /// Generates next 64-bit random integer using XorShift128+.
    @inline(__always)
    public mutating func nextUInt64() -> UInt64 {
        var s1 = state0
        let s0 = state1
        state0 = s0
        s1 ^= s1 << 23
        s1 ^= s1 >> 17
        s1 ^= s0
        s1 ^= s0 >> 26
        state1 = s1
        return s0 &+ s1
    }
    
    /// Generates uniform white noise in the range [-1.0, 1.0].
    @inline(__always)
    public mutating func nextWhite() -> Float {
        let rand = nextUInt64()
        // Map 53-bit mantissa to [0.0, 1.0) then scale to [-1.0, 1.0]
        let float01 = Float(rand >> 11) * (1.0 / Float(1 << 53))
        return (float01 * 2.0) - 1.0
    }
    
    /// Generates pink noise with a -3dB/octave roll-off using Paul Kellet's filter.
    @inline(__always)
    public mutating func nextPink() -> Float {
        let white = nextWhite()
        b0 = 0.99886 * b0 + white * 0.0555179
        b1 = 0.99332 * b1 + white * 0.0750759
        b2 = 0.96900 * b2 + white * 0.1538520
        b3 = 0.86650 * b3 + white * 0.3104856
        let pink = b0 + b1 + b2 + b3 + white * 0.5362
        return pink * 0.11 // Scale to approximate [-1.0, 1.0]
    }
    
    /// Generates Brownian (red) noise with a -6dB/octave roll-off via leaky integration.
    @inline(__always)
    public mutating func nextBrown() -> Float {
        let white = nextWhite()
        brownState = (brownState * 0.98) + (white * 0.02)
        // Normalize gain
        return brownState * 3.5
    }
}
