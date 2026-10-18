import Foundation

/// Thread-safe observable parameters controlling all procedural sound generators.
public final class SoundParameters: @unchecked Sendable {
    private let lock = NSLock()
    
    // Generator intensities (0.0 ... 1.0)
    private var _rainIntensity: Float = 0.65
    private var _rainSurfaceResonance: Float = 2400.0 // 1200Hz (glass) to 4500Hz (tin roof)
    private var _thunderIntensity: Float = 0.25
    private var _fireIntensity: Float = 0.40
    private var _windIntensity: Float = 0.30
    private var _binauralVolume: Float = 0.20
    private var _binauralWaveType: BinauralWaveType = .alpha
    private var _masterVolume: Float = 0.80
    private var _isPlaying: Bool = false
    
    public init() {}
    
    public var rainIntensity: Float {
        get { lock.withLock { _rainIntensity } }
        set { lock.withLock { _rainIntensity = max(0.0, min(1.0, newValue)) } }
    }
    
    public var rainSurfaceResonance: Float {
        get { lock.withLock { _rainSurfaceResonance } }
        set { lock.withLock { _rainSurfaceResonance = max(800.0, min(5000.0, newValue)) } }
    }
    
    public var thunderIntensity: Float {
        get { lock.withLock { _thunderIntensity } }
        set { lock.withLock { _thunderIntensity = max(0.0, min(1.0, newValue)) } }
    }
    
    public var fireIntensity: Float {
        get { lock.withLock { _fireIntensity } }
        set { lock.withLock { _fireIntensity = max(0.0, min(1.0, newValue)) } }
    }
    
    public var windIntensity: Float {
        get { lock.withLock { _windIntensity } }
        set { lock.withLock { _windIntensity = max(0.0, min(1.0, newValue)) } }
    }
    
    public var binauralVolume: Float {
        get { lock.withLock { _binauralVolume } }
        set { lock.withLock { _binauralVolume = max(0.0, min(1.0, newValue)) } }
    }
    
    public var binauralWaveType: BinauralWaveType {
        get { lock.withLock { _binauralWaveType } }
        set { lock.withLock { _binauralWaveType = newValue } }
    }
    
    public var masterVolume: Float {
        get { lock.withLock { _masterVolume } }
        set { lock.withLock { _masterVolume = max(0.0, min(1.0, newValue)) } }
    }
    
    public var isPlaying: Bool {
        get { lock.withLock { _isPlaying } }
        set { lock.withLock { _isPlaying = newValue } }
    }
    
    /// Snapshots all current parameter values in a single atomic lock acquisition.
    public func snapshot() -> Snapshot {
        lock.withLock {
            Snapshot(
                rainIntensity: _rainIntensity,
                rainSurfaceResonance: _rainSurfaceResonance,
                thunderIntensity: _thunderIntensity,
                fireIntensity: _fireIntensity,
                windIntensity: _windIntensity,
                binauralVolume: _binauralVolume,
                binauralWaveType: _binauralWaveType,
                masterVolume: _masterVolume,
                isPlaying: _isPlaying
            )
        }
    }
    
    public struct Snapshot: Sendable {
        public let rainIntensity: Float
        public let rainSurfaceResonance: Float
        public let thunderIntensity: Float
        public let fireIntensity: Float
        public let windIntensity: Float
        public let binauralVolume: Float
        public let binauralWaveType: BinauralWaveType
        public let masterVolume: Float
        public let isPlaying: Bool
    }
}
