import XCTest
@testable import CubicLookupTable

final class CubicLookupTableTests: XCTestCase {

    func test_fx_table() {
        let table = CubicLookupTable<Double>(
            a: 0,
            b: .pi/2,
            dxMin: 0.00001,
            dxMax: 0.001,
            df: 0.000001,
            f: { x in sin(x) },
            fp: { x in cos(x) }
        )!
        let n = 10_000
        let dx = (Double.pi/2) / Double(n-1)
        var `var`: Double = .zero
        for k in 0 ..< n {
            let x = Double(k) * dx
            let actualValue = Darwin.sin(x)
            let  tableValue = table.f(x)
            let diff = actualValue - tableValue
            `var` += diff * diff
        }
        `var` /= Double(n)
        let std = sqrt(`var`)
        XCTAssert(std <= table.df, "std: \(std), df: \(table.df)")
    }

    func test_fpx_table() {
        let table = CubicLookupTable<Double>(
            a: 0,
            b: .pi/2,
            dxMin: 0.00001,
            dxMax: 0.001,
            df: 0.000001,
            f: { x in sin(x) },
            fp: { x in cos(x) }
        )!
        let n = 10_000
        let dx = (Double.pi/2) / Double(n-1)
        var `var`: Double = .zero
        for k in 0 ..< n {
            let x = Double(k) * dx
            let actualValue = Darwin.sin(x)
            let  tableValue = table.f(x)
            let diff = actualValue - tableValue
            `var` += diff * diff
        }
        `var` /= Double(n)
        let std = sqrt(`var`)
        XCTAssert(std <= table.df, "std: \(std), df: \(table.df)")
    }

    static var allTests = [
        ("test_fx_table", test_fx_table),
        ("test_fpx_table", test_fpx_table)
    ]

}
