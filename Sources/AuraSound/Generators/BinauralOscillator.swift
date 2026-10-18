import Foundation

/// Cognitive brainwave target states for binaural beats.
public enum BinauralWaveType: String, CaseIterable, Identifiable, Sendable {
    case gamma = "Gamma (40 Hz - Deep Focus)"
    case beta  = "Beta (18 Hz - Alert Coding)"
    case alpha = "Alpha (10 Hz - Flow State)"
    case theta = "Theta (6 Hz - Meditation)"
    
    public var id: String { rawValue }
    
    /// Frequency differential between left and right ears in Hz.
    public var differentialHz: Float {
        switch self {
        case .gamma: return 40.0
        case .beta:  return 18.0
        case .alpha: return 10.0
        case .theta: return 6.0
        }
    }
    
    /// Pleasant carrier base frequency in Hz.
    public var carrierHz: Float {
        switch self {
        case .gamma: return 240.0
        case .beta:  return 220.0
        case .alpha: return 200.0
        case .theta: return 180.0
        }
    }
}

/// Real-time dual-channel phase-shifted pure sine oscillator for generating binaural brainwave entrainment.
public struct BinauralOscillator: Sendable {
    public let sampleRate: Float
    public var waveType: BinauralWaveType
    public var carrierFrequency: Float
    
    private var phaseLeft: Float = 0.0
    private var phaseRight: Float = 0.0
    
    public init(
        sampleRate: Float = 48000.0,
        waveType: BinauralWaveType = .alpha
    ) {
        self.sampleRate = sampleRate
        self.waveType = waveType
        self.carrierFrequency = waveType.carrierHz
    }
    
    /// Updates wave type and recalculates target frequencies.
    public mutating func update(waveType: BinauralWaveType) {
        self.waveType = waveType
        self.carrierFrequency = waveType.carrierHz
    }
    
    /// Renders stereo binaural sine waves into stereo left and right non-interleaved buffers.
    public mutating func render(
        left: UnsafeMutablePointer<Float>,
        right: UnsafeMutablePointer<Float>,
        count: Int,
        volume: Float = 0.25
    ) {
        guard volume > 0.001 else { return }
        
        let delta = waveType.differentialHz
        let freqL = carrierFrequency - (delta * 0.5)
        let freqR = carrierFrequency + (delta * 0.5)
        
        let incL = (2.0 * Float.pi * freqL) / sampleRate
        let incR = (2.0 * Float.pi * freqR) / sampleRate
        
        for i in 0..<count {
            phaseLeft += incL
            if phaseLeft > 2.0 * Float.pi { phaseLeft -= 2.0 * Float.pi }
            
            phaseRight += incR
            if phaseRight > 2.0 * Float.pi { phaseRight -= 2.0 * Float.pi }
            
            let sampleL = sin(phaseLeft) * volume * 0.35
            let sampleR = sin(phaseRight) * volume * 0.35
            
            left[i] += sampleL
            right[i] += sampleR
        }
    }
}
