
import Model
import PlaygroundSupport
import UIKit

public class SimulationViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    // MARK: - Properties: UI
    private let containerView = UIView()
    private let pointsView: PointsView
    private let metricsView: MetricsView
    private let debugLabel = UILabel()

    // MARK: Model
    private let isInDebugMode: Bool = false
    private let finishCompletion: (() -> Void)?
    private var simulation: Simulation
    private var displayLink: CADisplayLink?
    private var simulationStartTime: Double = 0
    private var lastSimulationTime: Double = 0

    // MARK: - Initializers
    public init(configuration: Configuration, finishCompletion: (() -> Void)? = nil) {
        self.finishCompletion = finishCompletion
        simulation = Simulation(config: configuration)
        pointsView = PointsView(configuration: configuration)
        metricsView = MetricsView(configuration: configuration)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        startSimulation()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 1
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = CGFloat(simulation.configuration.fixed.pointRadius) * view.frame.width
    }

    // MARK: Simulation Start & Finish
    private func startSimulation() {
        simulationStartTime = CFAbsoluteTimeGetCurrent()
        lastSimulationTime = CFAbsoluteTimeGetCurrent()
        displayLink = CADisplayLink(target: self, selector: #selector(simulateIfNeeded))
        displayLink!.add(to: .current, forMode: .common)
    }

    private func finishSimulation() {
        finishCompletion?()
    }

    // MARK: Updating
    @objc
    private func simulateIfNeeded() {
        // Manage time
        let now = CFAbsoluteTimeGetCurrent()
        let timeSinceStart = now - simulationStartTime
        guard timeSinceStart <= simulation.configuration.simulationDuration else {
            displayLink?.invalidate()
            return metricsView.finishDrawing(inRelativeSpeed: true) { self.finishSimulation() }
        }

        let timeProgress = now - lastSimulationTime
        lastSimulationTime = now

        // Simulate
        simulate(timeProgress: timeProgress, timeSinceStart: timeSinceStart)
    }

    private func simulate(timeProgress: Double, timeSinceStart: Double) {
        // Acquire new data
        let points = simulation.simulate(timeProgress: timeProgress)
        let metrics = Metrics(points: points)
        let simulationWillGoOn = points.contains { $0.hasFuture(within: simulation.configuration.simulationDuration) }

        // Draw new data
        pointsView.set(points: points)
        metricsView.add(metrics: metrics, for: timeSinceStart, simulationDuration: simulation.configuration.simulationDuration, forceDrawing: !simulationWillGoOn)

        // Cancel simulation if nothing will happen
        if !simulationWillGoOn {
            // Simulation won't go on -> stop
            displayLink?.invalidate()
            metricsView.finishDrawing(inRelativeSpeed: false) {
                // Remove all dead points that haven't been removed yet
                self.pointsView.set(points: points.filter { if case .dead = $0.state { return false }; return true })

                // Delay a bit so that point drawing is finished correctly
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    // Finish simulation
                    self.finishSimulation()
                }
            }
        }
    }

    // MARK: View Setup
    private func setupView() {
        // Only setup once
        guard view.subviews.isEmpty else { return }

        // Disable autoresizing mask
        containerView.translatesAutoresizingMaskIntoConstraints = false
        pointsView.translatesAutoresizingMaskIntoConstraints = false
        metricsView.translatesAutoresizingMaskIntoConstraints = false
        debugLabel.translatesAutoresizingMaskIntoConstraints = false

        // Configure status label
        debugLabel.backgroundColor = .black
        debugLabel.textColor = .white
        debugLabel.numberOfLines = 0
        debugLabel.isHidden = !isInDebugMode

        // Add views
        containerView.addSubview(metricsView)
        containerView.addSubview(pointsView)
        view.addSubview(containerView)
        view.addSubview(debugLabel)

        // Configure constraints
        let constraints = [
            pointsView.widthAnchor.constraint(equalTo: pointsView.heightAnchor, multiplier: 2),
            metricsView.topAnchor.constraint(equalTo: containerView.topAnchor),
            metricsView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            metricsView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            pointsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            pointsView.topAnchor.constraint(equalTo: metricsView.bottomAnchor),
            pointsView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            pointsView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            pointsView.heightAnchor.constraint(equalTo: metricsView.heightAnchor),
            debugLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            debugLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            debugLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 20),
            containerView.rightAnchor.constraint(lessThanOrEqualTo: view.rightAnchor, constant: -20),
            containerView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 100),
            containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -100)
        ]

        let lessPrioConstraints: [NSLayoutConstraint] = [ containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ].map { $0.priority = UILayoutPriority(rawValue: 950); return $0 }

        NSLayoutConstraint.activate(constraints)
        NSLayoutConstraint.activate(lessPrioConstraints)
    }
}
