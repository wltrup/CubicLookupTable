import XCTest
@testable import CubicLookupTable

final class CubicTrigTableTests: XCTestCase {

    func test_sin_table_from_minus3pi_to_3pi() {
        let trigTable = CubicTrigTable<Float>(dxMin: 0.00001, dxMax: 0.001, df: 0.000001)!
        let n = 10_000
        let dx = 6.0 * Float.pi / Float(n-1)
        var `var`: Float = .zero
        for k in 0 ..< n {
            let x = -3.0 * Float.pi + Float(k) * dx
            let actualSine = Darwin.sin(x)
            let  tableSine = trigTable.sin(x)
            let diff = actualSine - tableSine
            `var` += diff * diff
        }
        `var` /= Float(n)
        let std = sqrt(`var`)
        XCTAssert(std <= trigTable.df)
    }

    func test_cos_table_from_minus3pi_to_3pi() {
        let trigTable = CubicTrigTable<Float>(dxMin: 0.00001, dxMax: 0.001, df: 0.000001)!
        let n = 10_000
        let dx = 6.0 * Float.pi / Float(n-1)
        var `var`: Float = .zero
        for k in 0 ..< n {
            let x = -3.0 * Float.pi + Float(k) * dx
            let actualSine = Darwin.cos(x)
            let  tableSine = trigTable.cos(x)
            let diff = actualSine - tableSine
            `var` += diff * diff
        }
        `var` /= Float(n)
        let std = sqrt(`var`)
        XCTAssert(std <= trigTable.df)
    }

    static var allTests = [
        ("test_sin_table_from_minus3pi_to_3pi", test_sin_table_from_minus3pi_to_3pi),
        ("test_cos_table_from_minus3pi_to_3pi", test_cos_table_from_minus3pi_to_3pi)
    ]

}
