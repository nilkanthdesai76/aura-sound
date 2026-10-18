import XCTest
@testable import AuraSound

final class FastNoiseTests: XCTestCase {
    
    func testWhiteNoiseBounds() {
        var noise = FastNoise(seed: 12345)
        var minVal: Float = 1.0
        var maxVal: Float = -1.0
        
        for _ in 0..<100_000 {
            let sample = noise.nextWhite()
            XCTAssertFalse(sample.isNaN)
            XCTAssertFalse(sample.isInfinite)
            XCTAssertTrue(sample >= -1.0 && sample <= 1.0)
            minVal = min(minVal, sample)
            maxVal = max(maxVal, sample)
        }
        
        // Ensure good distribution covering both positive and negative ranges
        XCTAssertTrue(minVal < -0.95)
        XCTAssertTrue(maxVal > 0.95)
    }
    
    func testPinkNoiseProperties() {
        var noise = FastNoise(seed: 54321)
        var sum: Float = 0.0
        let count = 50_000
        
        for _ in 0..<count {
            let sample = noise.nextPink()
            XCTAssertFalse(sample.isNaN)
            XCTAssertFalse(sample.isInfinite)
            sum += sample
        }
        
        // DC offset of pink noise should be near zero
        let mean = sum / Float(count)
        XCTAssertTrue(abs(mean) < 0.15, "Mean of pink noise should be near zero, got \(mean)")
    }
    
    func testBrownNoiseProperties() {
        var noise = FastNoise(seed: 99999)
        var sum: Float = 0.0
        let count = 50_000
        
        for _ in 0..<count {
            let sample = noise.nextBrown()
            XCTAssertFalse(sample.isNaN)
            XCTAssertFalse(sample.isInfinite)
            sum += sample
        }
        
        let mean = sum / Float(count)
        XCTAssertTrue(abs(mean) < 0.35, "Brown noise mean should remain stable")
    }
}
