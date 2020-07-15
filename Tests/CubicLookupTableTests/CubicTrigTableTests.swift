import XCTest
@testable import CubicLookupTable

final class CubicTrigTableTests: XCTestCase {

    func test_sin_table_from_minus3pi_to_3pi() {
        let table = CubicTrigTable<Float>(dxMin: 0.00001, dxMax: 0.001, df: 0.000001)!
        let n = 10_000
        let dx = 6.0 * Float.pi / Float(n-1)
        var `var`: Float = .zero
        for k in 0 ..< n {
            let x = -3.0 * Float.pi + Float(k) * dx
            let actualValue = Darwin.sin(x)
            let  tableValue = table.sin(x)
            let diff = actualValue - tableValue
            `var` += diff * diff
        }
        `var` /= Float(n)
        let std = sqrt(`var`)
        XCTAssert(std <= table.df, "std: \(std), df: \(table.df)")
    }

    func test_cos_table_from_minus3pi_to_3pi() {
        let table = CubicTrigTable<Float>(dxMin: 0.00001, dxMax: 0.001, df: 0.000001)!
        let n = 10_000
        let dx = 6.0 * Float.pi / Float(n-1)
        var `var`: Float = .zero
        for k in 0 ..< n {
            let x = -3.0 * Float.pi + Float(k) * dx
            let actualValue = Darwin.cos(x)
            let  tableValue = table.cos(x)
            let diff = actualValue - tableValue
            `var` += diff * diff
        }
        `var` /= Float(n)
        let std = sqrt(`var`)
        XCTAssert(std <= table.df, "std: \(std), df: \(table.df)")
    }

    static var allTests = [
        ("test_sin_table_from_minus3pi_to_3pi", test_sin_table_from_minus3pi_to_3pi),
        ("test_cos_table_from_minus3pi_to_3pi", test_cos_table_from_minus3pi_to_3pi)
    ]

}
