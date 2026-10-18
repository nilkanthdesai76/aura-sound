import Foundation

/// 100% Procedural Campfire Generator with micro-spark crackle pops and combustion rumble.
public struct ProceduralFireGenerator: Sendable {
    public let sampleRate: Float
    private var noise: FastNoise
    
    // Combustion filters
    private var lowRumbleFilter: BiquadFilter
    private var hissFilter: BiquadFilter
    private var crackleFilterLeft: BiquadFilter
    private var crackleFilterRight: BiquadFilter
    
    // Crackle impulse states
    private var popEnvelopeLeft: Float = 0.0
    private var popEnvelopeRight: Float = 0.0
    
    public init(sampleRate: Float = 48000.0) {
        self.sampleRate = sampleRate
        self.noise = FastNoise(seed: 0x3344556677889900)
        
        self.lowRumbleFilter = BiquadFilter(type: .lowpass, cutoff: 140.0, q: 1.2, sampleRate: sampleRate)
        self.hissFilter = BiquadFilter(type: .bandpass, cutoff: 3200.0, q: 1.5, sampleRate: sampleRate)
        self.crackleFilterLeft = BiquadFilter(type: .bandpass, cutoff: 3800.0, q: 22.0, sampleRate: sampleRate)
        self.crackleFilterRight = BiquadFilter(type: .bandpass, cutoff: 4200.0, q: 25.0, sampleRate: sampleRate)
    }
    
    /// Renders procedural campfire sound into stereo non-interleaved left and right buffers.
    public mutating func render(
        left: UnsafeMutablePointer<Float>,
        right: UnsafeMutablePointer<Float>,
        count: Int,
        intensity: Float = 0.40
    ) {
        guard intensity > 0.001 else { return }
        
        let rumbleGain = intensity * 0.45
        let hissGain = intensity * 0.18
        let crackleThreshold = max(0.92, 0.992 - (intensity * 0.04))
        
        for i in 0..<count {
            // 1. Low combustion rumble
            let brown = noise.nextBrown()
            let rumble = lowRumbleFilter.process(brown) * rumbleGain
            
            // 2. High ember hiss
            let pink = noise.nextPink()
            let hiss = hissFilter.process(pink) * hissGain
            
            // 3. Micro-spark crackles (Left & Right)
            let whiteL = noise.nextWhite()
            let whiteR = noise.nextWhite()
            
            // Trigger sudden snap pops when white noise spikes above threshold
            if abs(whiteL) > crackleThreshold {
                popEnvelopeLeft = 1.0
                // Randomize crackle pitch
                let popFreq = Float.random(in: 2200.0...5500.0)
                crackleFilterLeft.update(cutoff: popFreq)
            }
            if abs(whiteR) > crackleThreshold {
                popEnvelopeRight = 1.0
                let popFreq = Float.random(in: 2400.0...5800.0)
                crackleFilterRight.update(cutoff: popFreq)
            }
            
            let popSampleL = crackleFilterLeft.process(whiteL * popEnvelopeLeft)
            let popSampleR = crackleFilterRight.process(whiteR * popEnvelopeRight)
            
            popEnvelopeLeft *= 0.985 // Fast decay
            popEnvelopeRight *= 0.985
            
            let crackleGain = intensity * 0.65
            let totalL = rumble + hiss + (popSampleL * crackleGain)
            let totalR = rumble + hiss + (popSampleR * crackleGain)
            
            left[i] += totalL
            right[i] += totalR
        }
    }
}
