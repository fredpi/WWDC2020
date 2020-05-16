
import UIKit
import Model

class PointsView: UIView {
    // MARK: - Properties
    private let configuration: Configuration
    private var points: [Point] = [] {
        didSet {
            points = points.filter { $0.isVisible }
        }
    }

    // MARK: - Initializers
    init(configuration: Configuration) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods: Life-Cycle
    override func layoutSubviews() {
        super.layoutSubviews()

        draw()
        layer.cornerRadius = CGFloat(configuration.fixed.pointRadius) * frame.width
    }

    // MARK: Drawing
    func set(points: [Point]) {
        self.points = points
        draw()
    }

    private func draw() {
        if subviews.count >= points.count {
            drawUsingExisting()
        } else {
            drawNew()
        }
    }

    private func drawUsingExisting() {
        subviews[0..<subviews.count - points.count].forEach { $0.removeFromSuperview() }

        for (index, view) in subviews.enumerated() {
            let point = points[index]
            let radius = CGFloat(configuration.fixed.pointRadius) * frame.width
            view.frame = CGRect(
                x: CGFloat(point.center.x) * frame.width - radius,
                y: CGFloat(point.center.y) * frame.width - radius, // Using width here is intentionally
                width: 2 * radius,
                height: 2 * radius
            )

            view.layer.zPosition = getZ(for: point.state)
            view.layer.cornerRadius = radius
            view.backgroundColor = point.color
            view.layer.borderColor = point.isFullyProtected ? UIColor.black.cgColor : UIColor.clear.cgColor
            view.layer.borderWidth = view.frame.width * 0.08
        }
    }

    private func drawNew() {
        let frame = self.frame
        var newViews = [UIView]()
        for point in points {
            let radius = CGFloat(configuration.fixed.pointRadius) * frame.width
            let view = UIView(
                frame: CGRect(
                    x: CGFloat(point.center.x) * frame.width - radius,
                    y: CGFloat(point.center.y) * frame.width - radius, // Using width here is intentionally
                    width: 2 * radius,
                    height: 2 * radius
                )
            )

            view.layer.zPosition = getZ(for: point.state)
            view.layer.cornerRadius = radius
            view.layer.masksToBounds = true
            view.backgroundColor = point.color
            view.layer.borderColor = point.isFullyProtected ? UIColor.black.cgColor : UIColor.clear.cgColor
            view.layer.borderWidth = view.frame.width * 0.08
            newViews.append(view)
        }

        subviews.forEach { $0.removeFromSuperview() }
        newViews.forEach { addSubview($0) }
    }

    // MARK: Helpers
    private func setupView() {
        backgroundColor = .white
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    private func getZ(for state: State) -> CGFloat {
        switch state {
        case .dead:
            return 1

        case .infectious:
            return 2

        case .exposed:
            return 3

        case .susceptible:
            return 4

        case .immune:
            return 5
        }
    }
}
