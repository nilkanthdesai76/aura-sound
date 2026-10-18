import XCTest
@testable import AuraSound

final class SoftLimiterTests: XCTestCase {
    
    func testSoftLimiterClampsExtremeSignals() {
        let limiter = SoftLimiter(ceiling: 0.98)
        let count = 1000
        let buffer = UnsafeMutablePointer<Float>.allocate(capacity: count)
        defer { buffer.deallocate() }
        
        // Feed extremely hot signal (+12dBFS: amplitudes up to 4.0)
        for i in 0..<count {
            buffer[i] = sin(Float(i) * 0.1) * 4.0
        }
        
        limiter.process(buffer: buffer, count: count)
        
        for i in 0..<count {
            XCTAssertFalse(buffer[i].isNaN)
            XCTAssertFalse(buffer[i].isInfinite)
            XCTAssertTrue(buffer[i] <= 0.98 + 0.0001)
            XCTAssertTrue(buffer[i] >= -0.98 - 0.0001)
        }
    }
}
