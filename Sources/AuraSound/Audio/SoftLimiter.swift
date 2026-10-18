import Foundation
import Accelerate

/// Real-time soft-knee peak limiter and waveshaper using tanh analog saturation.
public struct SoftLimiter: Sendable {
    public var ceiling: Float
    
    public init(ceiling: Float = 0.98) {
        self.ceiling = ceiling
    }
    
    /// Waveshapes a single sample smoothly using tanh saturation.
    @inline(__always)
    public func process(_ sample: Float) -> Float {
        // Fast rational approximation of tanh(x) for real-time audio:
        // tanh(x) ≈ x * (27 + x^2) / (27 + 9*x^2) for |x| < 3, clamped at +/- 1
        if sample > 3.0 { return ceiling }
        if sample < -3.0 { return -ceiling }
        let x2 = sample * sample
        let rationalTanh = sample * (27.0 + x2) / (27.0 + 9.0 * x2)
        return rationalTanh * ceiling
    }
    
    /// Applies soft-clipping and bounds clamping across a buffer using SIMD.
    public func process(buffer: UnsafeMutablePointer<Float>, count: Int) {
        for i in 0..<count {
            buffer[i] = process(buffer[i])
        }
        
        // Safety hardware clamp
        var low = -ceiling
        var high = ceiling
        vDSP_vclip(buffer, 1, &low, &high, buffer, 1, vDSP_Length(count))
    }
}
