
import Foundation

public struct Metrics {
    // MARK: - Properties
    public let susceptible: Double
    public let exposed: Double
    public let infectious: Double
    public let dead: Double
    public let immune: Double

    public static let zero: Metrics = .init(points: [])

    // MARK: - Initializers
    public init(points: [Point]) {
        var total = Double(points.count)
        if total == 0 { total = 1 }

        susceptible = Double(points.filter { $0.state == .susceptible }.count) / total
        exposed = Double(points.filter { if case .exposed = $0.state { return true }; return false }.count) / total
        infectious = Double(points.filter { if case .infectious = $0.state { return true }; return false }.count) / total
        dead = Double(points.filter { if case .dead = $0.state { return true }; return false }.count) / total
        immune = Double(points.filter { if case .immune = $0.state { return true }; return false }.count) / total
    }
}
