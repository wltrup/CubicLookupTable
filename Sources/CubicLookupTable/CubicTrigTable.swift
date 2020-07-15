import Foundation

/// Builds a look-up table for `sin(x)` and `cos(x)`, in the real line,
/// using *dynamic sampling* and *cubic* interpolation.

public struct CubicTrigTable <T: BinaryFloatingPoint> {

    /// The lower end of the canonical interval `[0, pi/2]` for which to build the look-up table.
    public let a: T = .zero

    /// The upper end of the canonical interval `[0, pi/2]` for which to build the look-up table.
    public let b: T = 0.5 * .pi

    /// The smallest acceptable value of the increment in the independent value `x`.
    /// Note that `dxMin` must satisfy the conditions `dxMax > dxMin > 0`.
    public let dxMin: T

    /// The largest acceptable value of the increment in the independent value `x`.
    /// Note that `dxMax` must satisfy the conditions `dxMax > dxMin > 0`.
    public let dxMax: T

    /// The desired precision for the values of `sin(x)` and `cos(x)`.
    /// Note that `df` must satisfy the condition `df > 0`.
    public let df: T

    /// Convenience value.
    public let piOver2 = 0.5 * T.pi

    /// Convenience value.
    public let pi = T.pi

    /// Convenience value.
    public let threePiOver2 = 1.5 * T.pi

    /// Convenience value.
    public let twoPi = 2.0 * T.pi

    /// The number of values stored in the table.
    public var size: Int { sinTable.size }

    /// Returns the value of `sin(x)` by retrieving it from the table, if it exists there,
    /// or computes it by interpolating between the two values in the table that bracket
    /// the argument `x`.
    ///
    /// - Parameter x:
    /// The value for which to retrieve or compute `sin(x)`.
    ///
    /// - Returns:
    /// The retrieved or computed value of `sin(x)`.
    ///
    public func sin(_ x: T) -> T {
        guard x >= 0 else { return -sin(-x) }
        guard x != .zero && x != self.pi &&  x != self.twoPi else { return .zero }
        guard x != self.piOver2 else { return 1 }
        guard x != self.threePiOver2 else { return -1 }
        if x < self.piOver2 {
            return sinTable.f(x)
        } else if x < self.pi {
            return sin(self.pi - x)
        } else if x < self.twoPi {
            return -sin(x - self.pi)
        } else {
            return sin( x.truncatingRemainder(dividingBy: self.twoPi) )
        }
    }

    /// Returns the value of `cos(x)` using the identity `cos(x) = sin(x + pi/2)`.
    ///
    /// - Parameter x:
    /// The value for which to retrieve or compute `cos(x)`.
    ///
    /// - Returns:
    /// The retrieved or computed value of `cos(x)`.
    ///
    public func cos(_ x: T) -> T {
        sin(x + self.piOver2)
    }

    /// Initialises a look-up table for `sin(x)` and `cos(x)`.
    ///
    /// - Parameters:
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
    ///   The desired precision for the values of `sin(x)` and `cos(x)`.
    ///   Note that `df` must satisfy the condition `df > 0`.
    ///
    public init?(dxMin: T, dxMax: T, df: T) {

        guard dxMin > 0 else { return nil }
        guard dxMax > dxMin else { return nil }
        guard df > 0 else { return nil }

        self.dxMin = dxMin
        self.dxMax = dxMax
        self.df = df

        self.sinTable = CubicLookupTable<T>(
            a: .zero,
            b: 0.5 * .pi,
            dxMin: dxMin,
            dxMax: dxMax,
            df: df,
            f: { (x: T) in T(Darwin.sin(Double(x))) },
            fp: { (x: T) in T(Darwin.cos(Double(x))) }
        )!

    }

    private let sinTable: CubicLookupTable<T>

}
