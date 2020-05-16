
import Model
import UIKit

class DiagramView: UIView {
    // MARK: - Properties: UI
    private let susceptibleView = UIView()
    private let immuneView = UIView()
    private let exposedView = UIView()
    private let infectiousView = UIView()
    private let deadView = UIView()

    private let hidingView = UIView()
    private var hidingViewWidthConstraint: NSLayoutConstraint!

    private let allViews: [UIView]

    // MARK: Model
    var simulationDuration: Double = 0
    private var lastHidingViewTime: Double = 0

    // MARK: - Initializers
    init() {
        allViews = [immuneView, susceptibleView, exposedView, infectiousView, deadView]
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    func draw(metricsArray: [MetricsView.MetricsArrayItem]) {
        // Fix frame
        let frame = self.frame

        // Create paths
        let susceptiblePath = UIBezierPath()
        let immunePath = UIBezierPath()
        let exposedPath = UIBezierPath()
        let infectiousPath = UIBezierPath()
        let deadPath = UIBezierPath()
        let allPaths = [immunePath, susceptiblePath, exposedPath, infectiousPath, deadPath]
        allPaths.forEach { $0.move(to: .init(x: 0, y: frame.height)) }
        var relativeTime: CGFloat = 0

        for (time, metrics) in metricsArray {
            relativeTime = CGFloat(time / simulationDuration)

            let deadHeight = CGFloat(metrics.dead) * frame.height
            let infectiousHeight = CGFloat(metrics.infectious) * frame.height + deadHeight
            let exposedHeight = CGFloat(metrics.exposed) * frame.height + infectiousHeight
            let susceptibleHeight = CGFloat(metrics.susceptible) * frame.height + exposedHeight
            let immuneHeight = CGFloat(metrics.immune) * frame.height + susceptibleHeight

            deadPath.addLine(to: .init(x: relativeTime * frame.width, y: frame.height - deadHeight))
            infectiousPath.addLine(to: .init(x: relativeTime * frame.width, y: frame.height - infectiousHeight))
            exposedPath.addLine(to: .init(x: relativeTime * frame.width, y: frame.height - exposedHeight))
            susceptiblePath.addLine(to: .init(x: relativeTime * frame.width, y: frame.height - susceptibleHeight))
            immunePath.addLine(to: .init(x: relativeTime * frame.width, y: frame.height - immuneHeight))
        }

        allPaths.forEach { $0.addLine(to: .init(x: relativeTime * frame.width, y: frame.height)) }
        allPaths.forEach { $0.close() }

        // Apply paths
        zip(allViews, allPaths).forEach { view, path in
            if let shapeLayer = (view.layer.sublayers?.compactMap { $0 as? CAShapeLayer }.first) {
                shapeLayer.path = path.cgPath
            } else {
                let layer = CAShapeLayer()
                layer.path = path.cgPath
                layer.fillColor = color(for: view).cgColor
                view.layer.addSublayer(layer)
            }
        }
    }

    func finishDrawing(inRelativeSpeed: Bool, completion: @escaping () -> Void) {
        let duration = inRelativeSpeed ? TimeInterval(hidingViewWidthConstraint.constant / frame.width) * simulationDuration : 1
        setHidingViewConstraint(for: simulationDuration)
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            self.layoutIfNeeded()
        }, completion: { _ in completion() })
    }

    func setHidingViewConstraint(for time: Double? = nil) {
        lastHidingViewTime = time ?? lastHidingViewTime
        hidingViewWidthConstraint.constant = min(1, max(0, 1 - CGFloat(lastHidingViewTime / simulationDuration))) * frame.width
    }

    // MARK: Helpers
    private func setupView() {
        hidingViewWidthConstraint = hidingView.widthAnchor.constraint(equalToConstant: frame.width)

        // Manage diagram sub views
        allViews.forEach { view in
            view.backgroundColor = .clear
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)

            let constraints = [
                view.topAnchor.constraint(equalTo: topAnchor),
                view.bottomAnchor.constraint(equalTo: bottomAnchor),
                view.leftAnchor.constraint(equalTo: leftAnchor),
                view.rightAnchor.constraint(equalTo: rightAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }

        // Manage hiding view
        hidingView.backgroundColor = .white
        hidingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hidingView)

        let constraints = [
            hidingView.topAnchor.constraint(equalTo: topAnchor),
            hidingView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hidingViewWidthConstraint!,
            hidingView.rightAnchor.constraint(equalTo: rightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    private func color(for view: UIView) -> UIColor {
        switch view {
        case susceptibleView:
            return State.susceptible.color

        case immuneView:
            return State.immune(timeSinceExposal: 0, future: nil).color

        case exposedView:
            return State.exposed(timeSinceExposal: 0, future: nil).color

        case infectiousView:
            return State.infectious(timeSinceExposal: 0, future: nil).color

        case deadView:
            return State.dead(timeSinceDeath: 0).color

        default:
            return .black
        }
    }
}
