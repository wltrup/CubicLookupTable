# CubicLookupTable
![](https://img.shields.io/badge/platforms-iOS%2010%20%7C%20tvOS%2010%20%7C%20watchOS%204%20%7C%20macOS%2010.14-red)
[![Xcode](https://img.shields.io/badge/Xcode-11-blueviolet.svg)](https://developer.apple.com/xcode)
[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/wltrup/CubicLookupTable)
![GitHub](https://img.shields.io/github/license/wltrup/CubicLookupTable)

## What

**CubicLookupTable** is a Swift Package Manager package for iOS/tvOS (10.0 and above), watchOS (4.0 and above), and macOS (10.14 and above), under Swift 5.0 and above,  that efficiently implements a generic (in the Swift sense) *cubic*-interpolated and dynamically-sampled look-up table: given a function `f(x)` and its derivative `f'(x)`, a table is built that stores values of `x` and `f(x)` at specific points in some interval `[a,b]` provided by the client code. The derivative is necessary to dynamically determine  where to sample `f(x)` for maximum efficiency and accuracy.

For a *linearly*-interpolated version of this package, head to [LinearLookupTable](https://github.com/wltrup/LinearLookupTable).

Which one should you choose to use? That depends entirely on your needs. The main advantage of a linearly-interpolated table is that it's cheaper, both computationally and memory-wise, than a cubic-interpolated table but it's also less accurate for the same table size. Also, linear interpolation does not preserve the continuity of the interpolated function's derivative. If that's important to you, you should use a cubic-interpolated table.

```swift
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

    /// The number of pairs of values `(x, f(x))` stored in the table.
    public var size: Int

    /// Returns the value of `f(x)` by retrieving it from the table, if it exists there,
    /// or computes it by interpolating between the two values in the table that bracket
    /// the argument `x`. Note that `x` should be in the closed range `[a,b]`. No error
    /// is produced if it's not, and a result is interpolated, but it may be wildly innacurate.
    ///
    /// - Parameter x:
    /// The value for which to retrieve or compute `f(x)`. For accurate results, make sure
    /// that `x` is in the range `[a,b]`.
    ///
    /// - Returns:
    /// The retrieved or computed value of `f(x)`.
    ///
    public func f(_ x: T) -> T

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
    )

}
```

As a useful example in itself, the package also provides the `CubicTrigTable` type, which implements *cubic*-interpolated look-up tables for both `sin(x)` and `cos(x)`:

```swift
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
    public var size: Int

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
    public func sin(_ x: T) -> T

    /// Returns the value of `cos(x)` using the identity `cos(x) = sin(x + pi/2)`.
    ///
    /// - Parameter x:
    /// The value for which to retrieve or compute `cos(x)`.
    ///
    /// - Returns:
    /// The retrieved or computed value of `cos(x)`.
    ///
    public func cos(_ x: T) -> T

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
    public init?(dxMin: T, dxMax: T, df: T)

}
```

Lastly, for a mathematical description of the details involved in building these tables, you may want to take a look at [Designing and building efficient look-up tables](./lookup_tables.pdf). 

## Installation

**CubicLookupTable** is provided only as a Swift Package Manager package, because I'm moving away from CocoaPods and Carthage, and can be easily installed directly from Xcode.

## Author

Wagner Truppel, trupwl@gmail.com

## License

**CubicLookupTable** is available under the MIT license. See the [LICENSE](./LICENSE) file for more info.
