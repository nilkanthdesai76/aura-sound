import XCTest
@testable import AuraSound

final class ProceduralGeneratorTests: XCTestCase {
    
    func testRainGeneratorOutput() {
        var rain = ProceduralRainGenerator(sampleRate: 48000.0)
        let count = 4800 // 100ms
        let left = UnsafeMutablePointer<Float>.allocate(capacity: count)
        let right = UnsafeMutablePointer<Float>.allocate(capacity: count)
        defer {
            left.deallocate()
            right.deallocate()
        }
        
        left.initialize(repeating: 0.0, count: count)
        right.initialize(repeating: 0.0, count: count)
        
        rain.render(left: left, right: right, count: count, intensity: 0.70)
        
        var energyL: Float = 0.0
        var energyR: Float = 0.0
        for i in 0..<count {
            XCTAssertFalse(left[i].isNaN)
            XCTAssertFalse(right[i].isNaN)
            energyL += left[i] * left[i]
            energyR += right[i] * right[i]
        }
        
        XCTAssertTrue(energyL > 0.01, "Rain generator must produce audio energy")
        XCTAssertTrue(energyR > 0.01, "Rain generator must produce audio energy")
    }
    
    func testThunderGeneratorOutput() {
        var thunder = ProceduralThunderGenerator(sampleRate: 48000.0)
        thunder.triggerThunder() // Force trigger
        
        let count = 4800
        let left = UnsafeMutablePointer<Float>.allocate(capacity: count)
        let right = UnsafeMutablePointer<Float>.allocate(capacity: count)
        defer {
            left.deallocate()
            right.deallocate()
        }
        
        left.initialize(repeating: 0.0, count: count)
        right.initialize(repeating: 0.0, count: count)
        
        thunder.render(left: left, right: right, count: count, intensity: 0.80)
        
        var hasSignal = false
        for i in 0..<count {
            XCTAssertFalse(left[i].isNaN)
            XCTAssertFalse(right[i].isNaN)
            if abs(left[i]) > 0.001 || abs(right[i]) > 0.001 {
                hasSignal = true
            }
        }
        XCTAssertTrue(hasSignal, "Triggered thunder must render active sound")
    }
    
    func testFireGeneratorOutput() {
        var fire = ProceduralFireGenerator(sampleRate: 48000.0)
        let count = 4800
        let left = UnsafeMutablePointer<Float>.allocate(capacity: count)
        let right = UnsafeMutablePointer<Float>.allocate(capacity: count)
        defer {
            left.deallocate()
            right.deallocate()
        }
        
        left.initialize(repeating: 0.0, count: count)
        right.initialize(repeating: 0.0, count: count)
        
        fire.render(left: left, right: right, count: count, intensity: 0.60)
        
        var hasSignal = false
        for i in 0..<count {
            XCTAssertFalse(left[i].isNaN)
            XCTAssertFalse(right[i].isNaN)
            if abs(left[i]) > 0.0001 {
                hasSignal = true
            }
        }
        XCTAssertTrue(hasSignal, "Fire generator must produce sound")
    }
    
    func testWindGeneratorOutput() {
        var wind = ProceduralWindGenerator(sampleRate: 48000.0)
        let count = 4800
        let left = UnsafeMutablePointer<Float>.allocate(capacity: count)
        let right = UnsafeMutablePointer<Float>.allocate(capacity: count)
        defer {
            left.deallocate()
            right.deallocate()
        }
        
        left.initialize(repeating: 0.0, count: count)
        right.initialize(repeating: 0.0, count: count)
        
        wind.render(left: left, right: right, count: count, intensity: 0.50)
        
        var energy: Float = 0.0
        for i in 0..<count {
            XCTAssertFalse(left[i].isNaN)
            energy += left[i] * left[i]
        }
        XCTAssertTrue(energy > 0.001, "Wind generator must produce sound")
    }
    
    func testBinauralOscillator() {
        var osc = BinauralOscillator(sampleRate: 48000.0, waveType: .alpha)
        let count = 4800
        let left = UnsafeMutablePointer<Float>.allocate(capacity: count)
        let right = UnsafeMutablePointer<Float>.allocate(capacity: count)
        defer {
            left.deallocate()
            right.deallocate()
        }
        
        left.initialize(repeating: 0.0, count: count)
        right.initialize(repeating: 0.0, count: count)
        
        osc.render(left: left, right: right, count: count, volume: 0.50)
        
        for i in 0..<count {
            XCTAssertFalse(left[i].isNaN)
            XCTAssertFalse(right[i].isNaN)
            XCTAssertTrue(abs(left[i]) <= 0.5)
            XCTAssertTrue(abs(right[i]) <= 0.5)
        }
    }
}
