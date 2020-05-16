
import Foundation
import UIKit // Not clean, but needed to put color definition here

public struct Point: Hashable {
    // MARK: - Properties
    let uuid: String = UUID().uuidString
    let configuration: Configuration

    public var center: Vector
    var nominalVelocity: Vector
    public var isFullyProtected: Bool
    public var state: State

    // MARK: Computed
    public var color: UIColor { return state.color }
    public var isVisible: Bool {
        switch state {
        case let .dead(timeSinceDeath) where timeSinceDeath > 1:
            return false

        default:
            return true
        }
    }

    var actualVelocity: Vector {
        switch state {
        case .dead:
            return .zero

        case .infectious:
            return configuration.behavior.infectiousSpeedReductionFactor * nominalVelocity

        default:
            return nominalVelocity
        }
    }

    // MARK: - Methods
    public func hasFuture(within simulationTime: Double) -> Bool {
        switch state {
        case .dead, .susceptible:
            return false

        case let .exposed(_, future), let .infectious(_, future), let .immune(_, future):
            return future != nil && future!.time <= simulationTime
        }
    }

    func hasCollided(with neighbor: Point) -> Bool {
        pow(center.x - neighbor.center.x, 2) + pow(center.y - neighbor.center.y, 2) < 4 * configuration.fixed.squaredPointRadius
    }

    // MARK: Equatable & Hashable Implementation
    public static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.uuid == rhs.uuid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
