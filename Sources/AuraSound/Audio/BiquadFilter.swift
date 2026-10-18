import Foundation

/// Filter topology types for the 2nd-order IIR biquad filter.
public enum BiquadFilterType: Sendable {
    case lowpass
    case highpass
    case bandpass
    case notch
}

/// 2nd-Order Direct Form II Transposed Biquad Filter.
/// Numerically stable across audio frequencies, allocation-free, and real-time safe.
public struct BiquadFilter: Sendable {
    public var type: BiquadFilterType
    public var cutoffFrequency: Float
    public var qFactor: Float
    public var sampleRate: Float
    
    // Normalized coefficients
    private var b0: Float = 1.0
    private var b1: Float = 0.0
    private var b2: Float = 0.0
    private var a1: Float = 0.0
    private var a2: Float = 0.0
    
    // Direct Form II Transposed delay states
    private var z1: Float = 0.0
    private var z2: Float = 0.0
    
    public init(
        type: BiquadFilterType,
        cutoff: Float,
        q: Float = 0.7071,
        sampleRate: Float = 48000.0
    ) {
        self.type = type
        self.cutoffFrequency = cutoff
        self.qFactor = q
        self.sampleRate = sampleRate
        recalculateCoefficients()
    }
    
    /// Updates cutoff frequency and recalculates filter coefficients.
    public mutating func update(cutoff: Float, q: Float? = nil) {
        self.cutoffFrequency = max(10.0, min(sampleRate * 0.49, cutoff))
        if let q = q {
            self.qFactor = max(0.1, q)
        }
        recalculateCoefficients()
    }
    
    /// Resets internal delay states.
    public mutating func reset() {
        z1 = 0.0
        z2 = 0.0
    }
    
    /// Processes a single audio sample through the Direct Form II Transposed filter.
    @inline(__always)
    public mutating func process(_ input: Float) -> Float {
        let output = (b0 * input) + z1
        z1 = (b1 * input) - (a1 * output) + z2
        z2 = (b2 * input) - (a2 * output)
        return output
    }
    
    /// Processes a contiguous buffer of samples in-place.
    public mutating func process(buffer: UnsafeMutablePointer<Float>, count: Int) {
        for i in 0..<count {
            buffer[i] = process(buffer[i])
        }
    }
    
    private mutating func recalculateCoefficients() {
        let omega = 2.0 * Float.pi * (cutoffFrequency / sampleRate)
        let sinOmega = sin(omega)
        let cosOmega = cos(omega)
        let alpha = sinOmega / (2.0 * qFactor)
        
        var a0: Float = 1.0
        
        switch type {
        case .lowpass:
            b0 = (1.0 - cosOmega) / 2.0
            b1 = 1.0 - cosOmega
            b2 = (1.0 - cosOmega) / 2.0
            a0 = 1.0 + alpha
            a1 = -2.0 * cosOmega
            a2 = 1.0 - alpha
            
        case .highpass:
            b0 = (1.0 + cosOmega) / 2.0
            b1 = -(1.0 + cosOmega)
            b2 = (1.0 + cosOmega) / 2.0
            a0 = 1.0 + alpha
            a1 = -2.0 * cosOmega
            a2 = 1.0 - alpha
            
        case .bandpass:
            b0 = alpha
            b1 = 0.0
            b2 = -alpha
            a0 = 1.0 + alpha
            a1 = -2.0 * cosOmega
            a2 = 1.0 - alpha
            
        case .notch:
            b0 = 1.0
            b1 = -2.0 * cosOmega
            b2 = 1.0
            a0 = 1.0 + alpha
            a1 = -2.0 * cosOmega
            a2 = 1.0 - alpha
        }
        
        // Normalize by a0
        let invA0 = 1.0 / a0
        b0 *= invA0
        b1 *= invA0
        b2 *= invA0
        a1 *= invA0
        a2 *= invA0
    }
}
