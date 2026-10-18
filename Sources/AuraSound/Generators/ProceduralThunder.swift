import Foundation

/// 100% Procedural Thunder Generator synthesizing deep, rolling atmospheric thunder.
public struct ProceduralThunderGenerator: Sendable {
    public let sampleRate: Float
    private var noise: FastNoise
    private var poisson: PoissonDistribution
    
    // Lowpass cascade for sub-bass rumble
    private var lowpass1: BiquadFilter
    private var lowpass2: BiquadFilter
    
    // Envelope states
    private var envelope: Float = 0.0
    private var envelopeTarget: Float = 0.0
    private var decayRate: Float = 0.99992
    private var samplesUntilNextStrike: Int
    
    // Panning & intensity of current thunder event
    private var panLeft: Float = 0.5
    private var panRight: Float = 0.5
    private var currentDrive: Float = 1.0
    
    public init(sampleRate: Float = 48000.0) {
        self.sampleRate = sampleRate
        self.noise = FastNoise(seed: 0x4567890123ABCDEF)
        self.poisson = PoissonDistribution(seed: 0xFEDCBA9876543210)
        
        self.lowpass1 = BiquadFilter(type: .lowpass, cutoff: 85.0, q: 0.7071, sampleRate: sampleRate)
        self.lowpass2 = BiquadFilter(type: .lowpass, cutoff: 65.0, q: 0.7071, sampleRate: sampleRate)
        
        // Initial wait time (8 to 20 seconds before first thunder)
        self.samplesUntilNextStrike = Int(sampleRate * Float.random(in: 8.0...20.0))
    }
    
    /// Renders procedural thunder into stereo non-interleaved left and right buffers.
    public mutating func render(
        left: UnsafeMutablePointer<Float>,
        right: UnsafeMutablePointer<Float>,
        count: Int,
        intensity: Float = 0.30
    ) {
        guard intensity > 0.001 else { return }
        
        for i in 0..<count {
            samplesUntilNextStrike -= 1
            if samplesUntilNextStrike <= 0 {
                triggerThunder()
                // Randomize next strike interval based on intensity (e.g. 15s to 45s between strikes)
                let minSec = max(8.0, 45.0 - (intensity * 35.0))
                let maxSec = minSec + 25.0
                samplesUntilNextStrike = Int(sampleRate * Float.random(in: minSec...maxSec))
            }
            
            // Advance envelope smoothly
            if envelope < envelopeTarget {
                envelope += 0.0005 // Attack phase
            } else {
                envelope *= decayRate // Long rolling decay phase
            }
            
            if envelope > 0.0005 {
                // Generate deep Brownian sub-bass noise
                let brown = noise.nextBrown()
                let filtered1 = lowpass1.process(brown)
                let filtered2 = lowpass2.process(filtered1)
                
                // Add secondary rumbling crackle
                let crackle = noise.nextWhite() * (filtered2 * filtered2)
                let rawThunder = (filtered2 * 0.85) + (crackle * 0.15)
                
                // Non-linear saturation waveshaper via tanh
                let driven = rawThunder * currentDrive * envelope
                let saturated = tanh(driven) * intensity
                
                left[i] += saturated * panLeft
                right[i] += saturated * panRight
            }
        }
    }
    
    /// Triggers an immediate manual thunder strike (e.g. for preview / test).
    public mutating func triggerThunder() {
        envelope = 0.05
        envelopeTarget = Float.random(in: 0.7...1.0)
        
        // Decay duration between 6.0 and 12.0 seconds:
        // decayRate^N ≈ 0.01 where N = seconds * sampleRate
        let durationSeconds = Float.random(in: 6.0...12.0)
        decayRate = exp(log(0.005) / (durationSeconds * sampleRate))
        
        currentDrive = Float.random(in: 1.8...3.2)
        
        // Random stereo location for strike
        let pan = Float.random(in: 0.15...0.85)
        panLeft = cos(pan * Float.pi * 0.5)
        panRight = sin(pan * Float.pi * 0.5)
    }
}
