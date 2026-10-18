import Foundation

/// Active raindrop impulse resonator state.
struct ActiveDroplet {
    var filter: BiquadFilter
    var envelope: Float
    var decay: Float
    var panLeft: Float
    var panRight: Float
    var isActive: Bool
}

/// 100% Procedural Rain Generator combining background atmospheric pink noise with Poisson droplet impacts.
public struct ProceduralRainGenerator: Sendable {
    public let sampleRate: Float
    private var noise: FastNoise
    private var poisson: PoissonDistribution
    
    // Background rainbed filter
    private var bedFilterLeft: BiquadFilter
    private var bedFilterRight: BiquadFilter
    
    // Droplet arrival tracking
    private var samplesUntilNextDroplet: Int = 0
    
    // Polyphonic droplet resonator pool (fixed size to avoid heap allocations on audio thread)
    private var droplets: [ActiveDroplet]
    private let maxDroplets = 24
    
    public init(sampleRate: Float = 48000.0) {
        self.sampleRate = sampleRate
        self.noise = FastNoise(seed: 0x9876543210ABCDEF)
        self.poisson = PoissonDistribution(seed: 0xFEDCBA0987654321)
        
        self.bedFilterLeft = BiquadFilter(type: .bandpass, cutoff: 2200.0, q: 0.8, sampleRate: sampleRate)
        self.bedFilterRight = BiquadFilter(type: .bandpass, cutoff: 2400.0, q: 0.8, sampleRate: sampleRate)
        
        // Pre-allocate fixed pool of droplet resonators
        var pool: [ActiveDroplet] = []
        pool.reserveCapacity(24)
        for _ in 0..<24 {
            let filter = BiquadFilter(type: .bandpass, cutoff: 2500.0, q: 15.0, sampleRate: sampleRate)
            pool.append(ActiveDroplet(
                filter: filter,
                envelope: 0.0,
                decay: 0.995,
                panLeft: 0.5,
                panRight: 0.5,
                isActive: false
            ))
        }
        self.droplets = pool
    }
    
    /// Synthesizes rain into stereo non-interleaved left and right buffers.
    public mutating func render(
        left: UnsafeMutablePointer<Float>,
        right: UnsafeMutablePointer<Float>,
        count: Int,
        intensity: Float = 0.65,
        surfaceResonance: Float = 2400.0
    ) {
        guard intensity > 0.001 else { return }
        
        // Update background filter cutoff based on surface resonance
        bedFilterLeft.update(cutoff: surfaceResonance)
        bedFilterRight.update(cutoff: surfaceResonance * 1.08)
        
        // Map intensity [0.0, 1.0] to droplet arrival rate lambda [5.0, 450.0]
        let lambda = 5.0 + (intensity * 445.0)
        let bedGain = intensity * 0.40
        let dropletGain = intensity * 0.55
        
        for i in 0..<count {
            // 1. Synthesize background atmospheric rain bed
            let pinkL = noise.nextPink()
            let pinkR = noise.nextPink()
            let rainBedL = bedFilterLeft.process(pinkL) * bedGain
            let rainBedR = bedFilterRight.process(pinkR) * bedGain
            
            // 2. Check for new droplet arrival
            samplesUntilNextDroplet -= 1
            if samplesUntilNextDroplet <= 0 {
                spawnDroplet(surfaceResonance: surfaceResonance)
                samplesUntilNextDroplet = poisson.nextIntervalInSamples(lambda: lambda, sampleRate: sampleRate)
            }
            
            // 3. Accumulate active droplets
            var dropL: Float = 0.0
            var dropR: Float = 0.0
            
            for d in 0..<maxDroplets {
                if droplets[d].isActive {
                    let impulse = noise.nextWhite() * droplets[d].envelope
                    let sample = droplets[d].filter.process(impulse)
                    dropL += sample * droplets[d].panLeft
                    dropR += sample * droplets[d].panRight
                    
                    droplets[d].envelope *= droplets[d].decay
                    if droplets[d].envelope < 0.001 {
                        droplets[d].isActive = false
                    }
                }
            }
            
            left[i] += rainBedL + (dropL * dropletGain)
            right[i] += rainBedR + (dropR * dropletGain)
        }
    }
    
    private mutating func spawnDroplet(surfaceResonance: Float) {
        for d in 0..<maxDroplets {
            if !droplets[d].isActive {
                // Randomize pitch around surface resonance [± 35%]
                let pitchFactor = 0.65 + ((noise.nextWhite() + 1.0) * 0.35)
                let dropFreq = max(800.0, min(5000.0, surfaceResonance * pitchFactor))
                
                // Randomize resonance Q [10.0 ... 30.0]
                let dropQ = 10.0 + ((noise.nextWhite() + 1.0) * 10.0)
                droplets[d].filter.update(cutoff: dropFreq, q: dropQ)
                droplets[d].filter.reset()
                
                droplets[d].envelope = 0.8 + ((noise.nextWhite() + 1.0) * 0.1)
                
                // Fast exponential decay (approx 2ms to 6ms duration)
                droplets[d].decay = 0.992 + ((noise.nextWhite() + 1.0) * 0.003)
                
                // Random stereo panning
                let pan = (noise.nextWhite() + 1.0) * 0.5
                droplets[d].panLeft = cos(pan * Float.pi * 0.5)
                droplets[d].panRight = sin(pan * Float.pi * 0.5)
                
                droplets[d].isActive = true
                break
            }
        }
    }
}
