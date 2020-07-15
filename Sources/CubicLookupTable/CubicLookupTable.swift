import Foundation
import RandomAccessCollectionBinarySearch

/// Builds a look-up table for a given function `f(x)` and its first derivative, `f'(x)`,
/// in the interval `a ≤ x ≤ b`, using *dynamic sampling* and *cubic* interpolation.

public struct CubicLookupTable <T: BinaryFloatingPoint> {

    /// The lower end of the closed interval `[a,b]` for which to build the look-up table.
    /// Note that `a` and `b` must satisfy the condition `a < b`.
    public let a: T

    /// The upper end of the closed interval `[a,b]` for which to build the look-up table.
    /// Note that `a` and `b` must satisfy the condition `a < b`.
    public let b: T

    /// The smallest acceptable value of the increment in the independent value `x`.
    /// Note that `dxMin` must satisfy the conditions `dxMax > dxMin > 0`.
    public let dxMin: T

    /// The largest acceptable value of the increment in the independent value `x`.
    /// Note that `dxMax` must satisfy the conditions `dxMax > dxMin > 0`.
    public let dxMax: T

    /// The desired precision for the dependent values `f(x)`.
    /// Note that `df` must satisfy the condition `df > 0`.
    public let df: T

    /// The number of triplets of values `(x, f(x), f'(x))` stored in the table.
    public var size: Int { table.count }

    /// Returns the value of `f(x)` by retrieving it from the table, if it exists there,
    /// or computes it by (cubic) interpolating between the two values in the table that
    /// bracket the argument `x`. Note that `x` should be in the closed range `[a,b]`. No
    /// error is produced if it's not, and a result is interpolated, but it may be wildly
    /// innacurate.
    ///
    /// - Parameter x:
    /// The value for which to retrieve or compute `f(x)`. For accurate results, make sure
    /// that `x` is in the range `[a,b]`.
    ///
    /// - Returns:
    /// The retrieved or computed value of `f(x)`.
    ///
    public func f(_ x: T) -> T {
        retrieveF(for: x)
    }

    /// Returns the value of `f'(x)` (the first derivative of `f` computed at `x`) by
    /// retrieving it from the table, if it exists there, or computes it by (linearly)
    /// interpolating between the two values in the table that bracket the argument `x`.
    /// Note that `x` should be in the closed range `[a,b]`. No error is produced if
    /// it's not, and a result is interpolated, but it may be wildly innacurate. The
    /// interpolation of `f'(x)` is linear because its cubic interpolation would require
    /// values for the second derivative.
    ///
    /// - Parameter x:
    /// The value for which to retrieve or compute `f'(x)`. For accurate results, make sure
    /// that `x` is in the range `[a,b]`.
    ///
    /// - Returns:
    /// The retrieved or computed value of `f'(x)`.
    ///
    public func fprime(_ x: T) -> T {
        retrieveFprime(for: x)
    }

    /// Initialises a look-up table.
    ///
    /// - Parameters:
    ///
    ///   - a:
    ///   The lower end of the closed interval `[a,b]` for which to build the look-up table.
    ///   Note that `a` and `b` must satisfy the condition `a < b`.
    ///
    ///   - b:
    ///   The upper end of the closed interval `[a,b]` for which to build the look-up table.
    ///   Note that `a` and `b` must satisfy the condition `a < b`.
    ///
    ///   - dxMin:
    ///   The smallest acceptable value of the increment in the independent value `x`.
    ///   Note that `dxMin` must satisfy the conditions `dxMax > dxMin > 0`.
    ///
    ///   - dxMax:
    ///   The largest acceptable value of the increment in the independent value `x`.
    ///   Note that `dxMax` must satisfy the conditions `dxMax > dxMin > 0`.
    ///
    ///   - df:
    ///   The desired precision for the dependent values `f(x)`.
    ///   Note that `df` must satisfy the condition `df > 0`.
    ///
    ///   - f:
    ///   The function `f(x)` for which to build the look-up table.
    ///
    ///   - fp:
    ///   The function that computes the derivative of `f(x)`.
    ///
    public init?(
        a: T,
        b: T,
        dxMin: T,
        dxMax: T,
        df: T,
        f: @escaping (T) -> T,
        fp: @escaping (T) -> T
    ) {

        guard a < b else { return nil }
        guard dxMin > 0 else { return nil }
        guard dxMax > dxMin else { return nil }
        guard df > 0 else { return nil }

        self.a = a
        self.b = b

        self.dxMin = dxMin
        self.dxMax = dxMax
        self.df = df

        self.f = f
        self.fp = fp

        buildTheTable()

    }

    private typealias X = T
    private typealias FX = T
    private typealias FPX = T

    private var f: (X) -> FX
    private var fp: (X) -> FPX

    private var table: [X: (FX, FPX)] = [:]
    private var sortedXs: [X] = []

}

// MARK: - Private API

extension CubicLookupTable {

    private mutating func buildTheTable() {

        var table: [X: (FX, FPX)] = [:]
        var sortedXs: [X] = []

        let sizeUpperBound = Int(ceil(abs(b-a) / dxMin)) + 1
        table.reserveCapacity(sizeUpperBound)
        sortedXs.reserveCapacity(sizeUpperBound)

        var x: X = a
        var dx: X = .zero
        var f: FX = .zero
        var fp: FPX = .zero

        while x < b {
            x += dx
            x = min(x, b)
            f = self.f(x)
            fp = self.fp(x)
            table[x] = (f, fp)
            sortedXs += [x]
            fp = abs(fp)
            dx = fp == .zero
                ? dxMax
                : df / fp
            dx = min(max(dxMin, dx), dxMax)
        }

        self.table = table
        self.sortedXs = sortedXs

    }

    @inline(__always)
    private func retrieveF(for x: X) -> FX {

        if let (f, _) = table[x] {
            // x itself is in the table, so just return
            // its stored f(x) value
            return f
        }

        let (xk, xkp1, xkp1mxk) = retrieveXkXkp1(for: x)

        let (fk, fpk) = table[xk]!
        let (fkp1, fpkp1) = table[xkp1]!

        let xkp1mxksq = xkp1mxk * xkp1mxk
        let fkp1mfk = fkp1 - fk
        let fpkp1pfpk = fpkp1 + fpk

        let b = ( 3 * fkp1mfk - (fpkp1pfpk + fpk) * xkp1mxk ) / xkp1mxksq
        let c = ( fpkp1pfpk * xkp1mxk - 2 * fkp1mfk ) / (xkp1mxksq * xkp1mxk)

        let xmxk = (x - xk)
        return fk + (fpk + (b + c * xmxk) * xmxk) * xmxk

    }

    @inline(__always)
    private func retrieveFprime(for x: X) -> FX {

        if let (_, fp) = table[x] {
            // x itself is in the table, so just return
            // its stored f'(x) value
            return fp
        }

        let (xk, xkp1, xkp1mxk) = retrieveXkXkp1(for: x)

        let (_, fpk) = table[xk]!
        let (_, fpkp1) = table[xkp1]!

        return fpk + (fpkp1 - fpk) * (x - xk) / xkp1mxk

    }

    @inline(__always)
    private func retrieveXkXkp1(for x: X) -> (xk: FX, xkp1: FX, xkp1mxk: FX) {

        let xk: X
        let xkp1: X

        if x < a {
            xk = sortedXs[0] // a
            xkp1 = sortedXs[1]
        } else if x > b {
            xk = sortedXs.dropLast().last!
            xkp1 = sortedXs.last! // b
        } else { // a < x < b (x = a and x = b are handled by the first if let)
            let (lowIdx, _, highIdx) = sortedXs.binarySearchLoHi(for: x)
            guard let lo = lowIdx  else { fatalError("lowIdx is nil but should not be, for x = \(x)") }
            guard let hi = highIdx else { fatalError("highIdx is nil but should not be, for x = \(x)") }
            xk = sortedXs[lo]
            xkp1 = sortedXs[hi]
        }

        let xkp1mxk = xkp1 - xk
        guard xkp1mxk > 0 else { fatalError("x_(k+1) ≤ x_(k) but should not be, for x = \(x)") }

        return (xk, xkp1, xkp1mxk)

    }

}
