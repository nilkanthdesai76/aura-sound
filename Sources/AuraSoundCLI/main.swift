import Foundation
import AuraSound

@main
struct AuraSoundCLI {
    static func main() {
        print("\u{001B}[2J\u{001B}[H", terminator: "") // Clear terminal
        print("""
        \u{001B}[36m
           █████╗ ██╗   ██╗██████╗  █████╗ ███████╗ ██████╗ ██╗   ██╗███╗   ██╗██████╗ 
          ██╔══██╗██║   ██║██╔══██╗██╔══██╗██╔════╝██╔═══██╗██║   ██║████╗  ██║██╔══██╗
          ███████║██║   ██║██████╔╝███████║███████╗██║   ██║██║   ██║██╔██╗ ██║██║  ██║
          ██╔══██║██║   ██║██╔══██╗██╔══██║╚════██║██║   ██║██║   ██║██║╚██╗██║██║  ██║
          ██║  ██║╚██████╔╝██║  ██║██║  ██║███████║╚██████╔╝╚██████╔╝██║ ╚████║██████╔╝
          ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═════╝ 
        \u{001B}[0m
        \u{001B}[35m  ▶ 100% Mathematical Procedural Ambient DSP (Zero Audio Samples)\u{001B}[0m
        """)
        
        let engine = AuraSoundEngine.shared
        do {
            try engine.start()
        } catch {
            print("\u{001B}[31mError starting audio engine: \(error)\u{001B}[0m")
            return
        }
        
        print("""
        \u{001B}[33mControls:\u{001B}[0m
          [Space] Play/Pause    [T] Trigger Thunder Strike    [Q] Quit
          [1] Deep Flow Preset  [2] Midnight Storm Preset     [3] Cabin Fireplace
        """)
        
        // Background thread to monitor live VU meters
        let isRunning = ThreadSafeBoolean(true)
        
        let monitorThread = Thread {
            while isRunning.value {
                let snap = engine.parameters.snapshot()
                let rmsL = engine.currentRmsLeft
                let rmsR = engine.currentRmsRight
                
                let barsL = Int(min(1.0, rmsL * 5.0) * 20.0)
                let barsR = Int(min(1.0, rmsR * 5.0) * 20.0)
                
                let meterL = String(repeating: "█", count: barsL) + String(repeating: "░", count: 20 - barsL)
                let meterR = String(repeating: "█", count: barsR) + String(repeating: "░", count: 20 - barsR)
                
                let status = snap.isPlaying ? "\u{001B}[32m● PLAYING\u{001B}[0m" : "\u{001B}[33m❚❚ PAUSED\u{001B}[0m"
                
                print("\r\(status) | L: \u{001B}[36m[\(meterL)]\u{001B}[0m | R: \u{001B}[35m[\(meterR)]\u{001B}[0m (Rain: \(Int(snap.rainIntensity * 100))%, Fire: \(Int(snap.fireIntensity * 100))%)", terminator: "")
                fflush(stdout)
                Thread.sleep(forTimeInterval: 0.08)
            }
        }
        monitorThread.start()
        
        // Terminal raw input mode
        setbuf(stdin, nil)
        
        while isRunning.value {
            var char: UInt8 = 0
            if read(STDIN_FILENO, &char, 1) > 0 {
                switch char {
                case 32: // Space
                    try? engine.togglePlayPause()
                case 116, 84: // 't' or 'T'
                    engine.triggerThunder()
                case 49: // '1'
                    engine.apply(preset: SoundPreset.all[0])
                case 50: // '2'
                    engine.apply(preset: SoundPreset.all[1])
                case 51: // '3'
                    engine.apply(preset: SoundPreset.all[2])
                case 113, 81: // 'q' or 'Q'
                    isRunning.value = false
                    engine.pause()
                    print("\n\n\u{001B}[32mExiting AuraSound. Peaceful coding!\u{001B}[0m\n")
                    exit(0)
                default:
                    break
                }
            }
        }
    }
}

final class ThreadSafeBoolean: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Bool
    
    init(_ value: Bool) {
        self._value = value
    }
    
    var value: Bool {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
}
