
import Foundation
import UIKit // Not clean, but needed to put color definition here

public indirect enum State: Hashable {
    // MARK: - Subtypes
    public struct Future: Hashable {
        var time: Double
        var state: State
    }

    // MARK: - Cases
    case susceptible
    case exposed(timeSinceExposal: Double, future: Future?)
    case infectious(timeSinceExposal: Double, future: Future?)
    case dead(timeSinceDeath: Double)
    case immune(timeSinceExposal: Double, future: Future?)

    // MARK: - Properties
    public var color: UIColor {
        switch self {
        case .dead:
            return .black

        case .exposed:
            return UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)

        case .infectious:
            return UIColor(red: 0.8, green: 0, blue: 0.0, alpha: 1.0)

        case .susceptible:
            return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)

        case .immune:
            return UIColor(red: 0, green: 0.8, blue: 0, alpha: 1.0)
        }
    }

    public var readableDescription: String {
        switch self {
        case .dead:
            return "Dead"

        case .exposed:
            return "Exposed"

        case .infectious:
            return "Infectious"

        case .susceptible:
            return "Susceptible"

        case .immune:
            return "Immune"
        }
    }

    // MARK: - Methods
    func bumpedStateTime(by timeProgress: Double) -> State {
        switch self {
        case .susceptible:
            return self

        case let .dead(timeSinceDeath):
            return .dead(timeSinceDeath: timeSinceDeath + timeProgress)

        case let .exposed(timeSinceExposal, future):
            return .exposed(timeSinceExposal: timeSinceExposal + timeProgress, future: future)

        case let .infectious(timeSinceExposal, future):
            return .infectious(timeSinceExposal: timeSinceExposal + timeProgress, future: future)

        case let .immune(timeSinceExposal, future):
            return .immune(timeSinceExposal: timeSinceExposal + timeProgress, future: future)
        }
    }
}
