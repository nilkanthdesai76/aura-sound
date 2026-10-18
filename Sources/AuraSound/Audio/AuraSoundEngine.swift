import AVFoundation
import Accelerate

/// Master audio engine coordinating all procedural sound generators through a real-time AVAudioSourceNode.
public final class AuraSoundEngine: @unchecked Sendable {
    public static let shared = AuraSoundEngine()
    
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    
    public let parameters = SoundParameters()
    
    // Live metering telemetry for waveform visualization (updated every audio buffer)
    private let meterLock = NSLock()
    private var _currentRmsLeft: Float = 0.0
    private var _currentRmsRight: Float = 0.0
    
    public var currentRmsLeft: Float {
        meterLock.withLock { _currentRmsLeft }
    }
    public var currentRmsRight: Float {
        meterLock.withLock { _currentRmsRight }
    }
    
    // Reference to generators (accessible for manual triggers)
    private var thunderGenRef: UnsafeMutablePointer<ProceduralThunderGenerator>?
    
    public init() {
        setupAudioGraph()
    }
    
    deinit {
        engine.stop()
        if let ptr = thunderGenRef {
            ptr.deallocate()
        }
    }
    
    private func setupAudioGraph() {
        let sampleRate: Float = 48000.0
        guard let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 2) else {
            return
        }
        
        // Allocate generators on heap to persist within source node closure
        var rainGen = ProceduralRainGenerator(sampleRate: sampleRate)
        let thunderPtr = UnsafeMutablePointer<ProceduralThunderGenerator>.allocate(capacity: 1)
        thunderPtr.initialize(to: ProceduralThunderGenerator(sampleRate: sampleRate))
        self.thunderGenRef = thunderPtr
        
        var fireGen = ProceduralFireGenerator(sampleRate: sampleRate)
        var windGen = ProceduralWindGenerator(sampleRate: sampleRate)
        var binauralGen = BinauralOscillator(sampleRate: sampleRate)
        let limiter = SoftLimiter(ceiling: 0.98)
        let params = self.parameters
        
        let node = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            let count = Int(frameCount)
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            guard ablPointer.count >= 2,
                  let left = ablPointer[0].mData?.assumingMemoryBound(to: Float.self),
                  let right = ablPointer[1].mData?.assumingMemoryBound(to: Float.self) else {
                return noErr
            }
            
            // Fast clear buffer using Accelerate vDSP
            vDSP_vclr(left, 1, vDSP_Length(count))
            vDSP_vclr(right, 1, vDSP_Length(count))
            
            // Read current thread-safe parameter snapshot
            let snap = params.snapshot()
            guard snap.isPlaying else { return noErr }
            
            // Update binaural wave type if changed
            if binauralGen.waveType != snap.binauralWaveType {
                binauralGen.update(waveType: snap.binauralWaveType)
            }
            
            // Render individual procedural components into buffers
            rainGen.render(
                left: left,
                right: right,
                count: count,
                intensity: snap.rainIntensity,
                surfaceResonance: snap.rainSurfaceResonance
            )
            
            thunderPtr.pointee.render(
                left: left,
                right: right,
                count: count,
                intensity: snap.thunderIntensity
            )
            
            fireGen.render(
                left: left,
                right: right,
                count: count,
                intensity: snap.fireIntensity
            )
            
            windGen.render(
                left: left,
                right: right,
                count: count,
                intensity: snap.windIntensity
            )
            
            binauralGen.render(
                left: left,
                right: right,
                count: count,
                volume: snap.binauralVolume
            )
            
            // Master volume scale via vDSP
            var master = snap.masterVolume
            vDSP_vsmul(left, 1, &master, left, 1, vDSP_Length(count))
            vDSP_vsmul(right, 1, &master, right, 1, vDSP_Length(count))
            
            // Soft-limit & clip peaks to prevent digital harshness
            limiter.process(buffer: left, count: count)
            limiter.process(buffer: right, count: count)
            
            // Compute RMS for live telemetry
            var rmsL: Float = 0.0
            var rmsR: Float = 0.0
            vDSP_rmsqv(left, 1, &rmsL, vDSP_Length(count))
            vDSP_rmsqv(right, 1, &rmsR, vDSP_Length(count))
            
            self?.updateMeters(rmsL: rmsL, rmsR: rmsR)
            
            return noErr
        }
        
        self.sourceNode = node
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: format)
        engine.prepare()
    }
    
    private func updateMeters(rmsL: Float, rmsR: Float) {
        meterLock.withLock {
            _currentRmsLeft = rmsL
            _currentRmsRight = rmsR
        }
    }
    
    /// Starts audio playback.
    public func start() throws {
        if !engine.isRunning {
            try engine.start()
        }
        parameters.isPlaying = true
    }
    
    /// Pauses audio playback without unbinding CoreAudio hardware.
    public func pause() {
        parameters.isPlaying = false
    }
    
    /// Toggles play / pause state.
    public func togglePlayPause() throws {
        if parameters.isPlaying {
            pause()
        } else {
            try start()
        }
    }
    
    /// Triggers an immediate rolling thunder strike.
    public func triggerThunder() {
        thunderGenRef?.pointee.triggerThunder()
    }
    
    /// Applies a curated sound preset atomically.
    public func apply(preset: SoundPreset) {
        parameters.rainIntensity = preset.rainIntensity
        parameters.rainSurfaceResonance = preset.rainResonance
        parameters.thunderIntensity = preset.thunderIntensity
        parameters.fireIntensity = preset.fireIntensity
        parameters.windIntensity = preset.windIntensity
        parameters.binauralVolume = preset.binauralVolume
        parameters.binauralWaveType = preset.binauralWave
    }
}
