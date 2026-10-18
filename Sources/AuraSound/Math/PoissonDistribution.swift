import Foundation

/// Fast Poisson point process calculator for generating discrete arrival intervals on real-time audio threads.
public struct PoissonDistribution: Sendable {
    private var noise: FastNoise
    
    public init(seed: UInt64 = 0x123456789ABCDEF) {
        self.noise = FastNoise(seed: seed)
    }
    
    /// Returns the number of samples until the next event arrives given an event rate lambda (events/sec) and audio sample rate.
    /// Uses inverse transform sampling: Δt = -ln(U) / λ
    @inline(__always)
    public mutating func nextIntervalInSamples(lambda: Float, sampleRate: Float) -> Int {
        guard lambda > 0.001 else { return Int(sampleRate * 10.0) }
        
        // Generate uniform (0.0, 1.0]
        let u = max(0.000001, (noise.nextWhite() + 1.0) * 0.5)
        let deltaSeconds = -log(u) / lambda
        let samples = Int(deltaSeconds * sampleRate)
        return max(1, samples)
    }
    
    /// Evaluates if an event triggers in the current sample frame.
    @inline(__always)
    public mutating func shouldTrigger(probabilityPerSample: Float) -> Bool {
        let u = (noise.nextWhite() + 1.0) * 0.5
        return u < probabilityPerSample
    }
}
