import Foundation

/// 100% Procedural Wind Generator with dual LFO-modulated resonant bandpass sweeps.
public struct ProceduralWindGenerator: Sendable {
    public let sampleRate: Float
    private var noise: FastNoise
    
    // Sweeping bandpass filters
    private var windFilterLeft: BiquadFilter
    private var windFilterRight: BiquadFilter
    
    // Dual Low-Frequency Oscillators (LFOs) for gust swells
    private var lfoPhase1: Float = 0.0
    private var lfoPhase2: Float = 0.0
    private let lfoIncrement1: Float
    private let lfoIncrement2: Float
    
    public init(sampleRate: Float = 48000.0) {
        self.sampleRate = sampleRate
        self.noise = FastNoise(seed: 0x5566778899AABBCC)
        
        self.windFilterLeft = BiquadFilter(type: .bandpass, cutoff: 450.0, q: 2.2, sampleRate: sampleRate)
        self.windFilterRight = BiquadFilter(type: .bandpass, cutoff: 480.0, q: 2.2, sampleRate: sampleRate)
        
        // LFO 1: ~0.07 Hz (approx 14-second swell cycle)
        self.lfoIncrement1 = (2.0 * Float.pi * 0.07) / sampleRate
        // LFO 2: ~0.13 Hz (approx 7.7-second swell cycle)
        self.lfoIncrement2 = (2.0 * Float.pi * 0.13) / sampleRate
    }
    
    /// Renders procedural wind into stereo non-interleaved left and right buffers.
    public mutating func render(
        left: UnsafeMutablePointer<Float>,
        right: UnsafeMutablePointer<Float>,
        count: Int,
        intensity: Float = 0.35
    ) {
        guard intensity > 0.001 else { return }
        
        for i in 0..<count {
            // Advance LFO phases
            lfoPhase1 += lfoIncrement1
            if lfoPhase1 > 2.0 * Float.pi { lfoPhase1 -= 2.0 * Float.pi }
            
            lfoPhase2 += lfoIncrement2
            if lfoPhase2 > 2.0 * Float.pi { lfoPhase2 -= 2.0 * Float.pi }
            
            // Compound modulation: base frequency swells between 180Hz and 850Hz
            let lfoVal1 = (sin(lfoPhase1) + 1.0) * 0.5
            let lfoVal2 = (sin(lfoPhase2) + 1.0) * 0.5
            let compoundMod = (lfoVal1 * 0.65) + (lfoVal2 * 0.35)
            
            let targetCutoff = 180.0 + (compoundMod * 670.0 * intensity)
            windFilterLeft.update(cutoff: targetCutoff)
            windFilterRight.update(cutoff: targetCutoff * 1.12)
            
            // Noise source: mix of pink and brown for hollow atmospheric body
            let pink = noise.nextPink()
            let brown = noise.nextBrown()
            let inputNoise = (pink * 0.6) + (brown * 0.4)
            
            let windL = windFilterLeft.process(inputNoise)
            let windR = windFilterRight.process(inputNoise)
            
            // Gain scales with gust swell
            let gustGain = (0.3 + (compoundMod * 0.7)) * intensity * 0.50
            
            left[i] += windL * gustGain
            right[i] += windR * gustGain
        }
    }
}
