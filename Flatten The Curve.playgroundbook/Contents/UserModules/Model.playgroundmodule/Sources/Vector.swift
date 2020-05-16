
import Foundation

public struct Vector: Equatable {
    // MARK: - Properties
    public var x: Double
    public var y: Double

    public var isZero: Bool {
        x == 0 && y == 0
    }

    static let zero: Vector = .init(x: 0, y: 0)
}

// MARK: - Operators
public extension Vector {
    // MARK: +
    static func +=(lhs: inout Vector, rhs: Vector) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    static func +=(lhs: inout Vector, rhs: Double) {
        lhs.x += rhs
        lhs.y += rhs
    }

    static func +(lhs: Vector, rhs: Vector) -> Vector {
        var lhs = lhs
        lhs += rhs
        return lhs
    }

    static func +(lhs: Vector, rhs: Double) -> Vector {
        var lhs = lhs
        lhs += rhs
        return lhs
    }

    // MARK: -
    static func -=(lhs: inout Vector, rhs: Vector) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    static func -=(lhs: inout Vector, rhs: Double) {
        lhs.x -= rhs
        lhs.y -= rhs
    }

    static func -(lhs: Vector, rhs: Vector) -> Vector {
        var lhs = lhs
        lhs -= rhs
        return lhs
    }

    static func -(lhs: Vector, rhs: Double) -> Vector {
        var lhs = lhs
        lhs -= rhs
        return lhs
    }

    // MARK: *
    static func *(lhs: Double, rhs: Vector) -> Vector {
        var rhs = rhs
        rhs.x *= lhs
        rhs.y *= lhs
        return rhs
    }

    static func *(lhs: Vector, rhs: Vector) -> Double {
        lhs.x * rhs.x + lhs.y + rhs.y
    }
}
