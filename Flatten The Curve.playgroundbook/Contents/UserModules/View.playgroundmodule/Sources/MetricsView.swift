
import Model
import UIKit

class MetricsView: UIView {
    // MARK: - Subtypes
    typealias MetricsArrayItem = (time: Double, metrics: Metrics)

    // MARK: - Properties: UI
    private let legendView = LegendView()
    private let diagramView = DiagramView()

    private var diagramViewRightConstraint: NSLayoutConstraint!
    private var legendViewLeftConstraint: NSLayoutConstraint!
    private var legendDiagramIntermediateConstraint: NSLayoutConstraint!

    // MARK: Model
    private let configuration: Configuration
    private var simulationDuration: Double = 0 {
        didSet {
            diagramView.simulationDuration = simulationDuration
        }
    }

    private var metricsArray: [MetricsArrayItem] = [] {
        didSet {
            if let last = metricsArray.last {
                legendView.set(metrics: last.metrics)
            }
        }
    }

    private var oldFrame: CGRect = .zero
    private let stepCount: Double = 200
    private var step: Double { simulationDuration / stepCount }

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

        if frame != oldFrame {
            oldFrame = frame

            // Putting into perspective to frame.height is intentional to achieve same spacing everywhere
            diagramViewRightConstraint.constant = -0.05 * frame.height
            legendViewLeftConstraint.constant = 0.05 * frame.height
            legendDiagramIntermediateConstraint.constant = -0.05 * frame.height

            diagramView.setHidingViewConstraint()
            diagramView.layer.cornerRadius = 2 * CGFloat(configuration.fixed.pointRadius) * frame.width

            draw()
        }
    }

    // MARK: Model
    func add(metrics: Metrics, for time: Double, simulationDuration: Double, forceDrawing: Bool = false) {
        self.simulationDuration = simulationDuration

        // Stepify
        let nextStep = metricsArray.last.map { $0.time + step } ?? 0
        if time >= nextStep || forceDrawing {
            let thisStep = floor(time / step) * step + (forceDrawing ? 1 : 0)
            metricsArray.append((time: thisStep, metrics: metrics))
            draw()
        } else {
            // Still update legend view
            legendView.set(metrics: metrics)
        }

        // Manage hiding view
        diagramView.setHidingViewConstraint(for: time - step)
        layoutIfNeeded()
    }

    // MARK: Drawing
    func draw() {
        diagramView.draw(metricsArray: metricsArray)
    }

    func finishDrawing(inRelativeSpeed: Bool, completion: @escaping () -> Void) {
        // Add last data point if needed
        if !metricsArray.contains { $0.time == simulationDuration }, let last = metricsArray.last {
            metricsArray.append((time: simulationDuration, metrics: last.metrics))
            draw()
        }

        // Forward to diagramView
        diagramView.finishDrawing(inRelativeSpeed: inRelativeSpeed, completion: completion)
    }

    // MARK: Helpers
    private func setupView() {
        diagramView.translatesAutoresizingMaskIntoConstraints = false
        diagramView.layer.masksToBounds = true
        addSubview(diagramView)

        legendView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(legendView)

        diagramViewRightConstraint = diagramView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        legendViewLeftConstraint = legendView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        legendDiagramIntermediateConstraint = legendView.rightAnchor.constraint(equalTo: diagramView.leftAnchor, constant: 0)

        let constraints = [
            diagramView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9),
            diagramView.centerYAnchor.constraint(equalTo: centerYAnchor),
            diagramViewRightConstraint!,
            diagramView.widthAnchor.constraint(equalTo: legendView.widthAnchor, multiplier: 6),
            legendView.centerYAnchor.constraint(equalTo: centerYAnchor),
            legendView.heightAnchor.constraint(equalTo: diagramView.heightAnchor),
            legendViewLeftConstraint!,
            legendDiagramIntermediateConstraint!
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
