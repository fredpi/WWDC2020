
import Model
import UIKit

class LegendView: UIView {
    // MARK: - Properties: UI
    let immuneView = LegendItemView()
    let susceptibleView = LegendItemView()
    let exposedView = LegendItemView()
    let infectiousView = LegendItemView()
    let deadView = LegendItemView()

    let allViews: [LegendItemView]

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
    func set(metrics: Metrics) {
        allViews.forEach {
            $0.viewModel = LegendItemView.ViewModel(
                color: mockState(for: $0).color,
                description: "(\(mockState(for: $0).readableDescription))",
                percentageString: perecentageString(for: $0, basedOn: metrics)
            )
        }
    }

    private func setupView() {
        allViews.forEach { addSubview($0) }

        var constraints: [NSLayoutConstraint] = [allViews.last!.bottomAnchor.constraint(equalTo: bottomAnchor)]
        for (index, view) in allViews.enumerated() {
            view.translatesAutoresizingMaskIntoConstraints = false
            constraints.append(
                contentsOf: [
                    view.leftAnchor.constraint(equalTo: leftAnchor),
                    view.rightAnchor.constraint(equalTo: rightAnchor),
                    view.topAnchor.constraint(equalTo: index == 0 ? topAnchor : allViews[index-1].bottomAnchor),
                    view.heightAnchor.constraint(equalTo: allViews[(index + 1) % allViews.count].heightAnchor)
                ]
            )
        }

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: Helpers
    private func mockState(for view: UIView) -> State {
        switch view {
        case susceptibleView:
            return State.susceptible

        case immuneView:
            return State.immune(timeSinceExposal: 0, future: nil)

        case exposedView:
            return State.exposed(timeSinceExposal: 0, future: nil)

        case infectiousView:
            return State.infectious(timeSinceExposal: 0, future: nil)

        case deadView:
            return State.dead(timeSinceDeath: 0)

        default:
            return State.dead(timeSinceDeath: 0)
        }
    }

    private func perecentageString(for view: UIView, basedOn metrics: Metrics) -> String {
        switch view {
        case susceptibleView:
            return "\(round(10000 * metrics.susceptible)/100) %"

        case immuneView:
            return "\(round(10000 * metrics.immune)/100) %"

        case exposedView:
            return "\(round(10000 * metrics.exposed)/100) %"

        case infectiousView:
            return "\(round(10000 * metrics.infectious)/100) %"

        case deadView:
            return "\(round(10000 * metrics.dead)/100) %"

        default:
            return ""
        }
    }
}
