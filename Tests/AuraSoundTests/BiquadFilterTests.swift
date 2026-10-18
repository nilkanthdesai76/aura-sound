import XCTest
@testable import AuraSound

final class BiquadFilterTests: XCTestCase {
    
    func testLowpassFilterStability() {
        var filter = BiquadFilter(type: .lowpass, cutoff: 1000.0, q: 0.7071, sampleRate: 48000.0)
        
        // Feed unit impulse: 1.0 followed by 0.0s
        var output = filter.process(1.0)
        XCTAssertFalse(output.isNaN)
        XCTAssertFalse(output.isInfinite)
        
        for _ in 0..<1000 {
            output = filter.process(0.0)
            XCTAssertFalse(output.isNaN)
            XCTAssertFalse(output.isInfinite)
        }
        
        // Output must decay to near zero
        XCTAssertTrue(abs(output) < 0.0001, "Filter impulse response must decay to zero")
    }
    
    func testHighpassFilterAttenuatesDC() {
        var filter = BiquadFilter(type: .highpass, cutoff: 500.0, q: 0.7071, sampleRate: 48000.0)
        
        // Feed constant DC signal (1.0)
        var output: Float = 0.0
        for _ in 0..<2000 {
            output = filter.process(1.0)
        }
        
        // Highpass filter must completely block DC offset (output -> 0)
        XCTAssertTrue(abs(output) < 0.01, "Highpass filter must block DC offset, got \(output)")
    }
    
    func testBandpassResonance() {
        var filter = BiquadFilter(type: .bandpass, cutoff: 2500.0, q: 15.0, sampleRate: 48000.0)
        
        // Feed unit impulse and verify ringing resonance
        let impulseResponse = (0..<100).map { i in
            filter.process(i == 0 ? 1.0 : 0.0)
        }
        
        // Response should oscillate and cross zero
        let zeroCrossings = zip(impulseResponse, impulseResponse.dropFirst()).filter { a, b in
            (a > 0 && b < 0) || (a < 0 && b > 0)
        }.count
        
        XCTAssertTrue(zeroCrossings > 5, "Resonant bandpass filter must oscillate")
    }
}
