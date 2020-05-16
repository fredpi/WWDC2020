
import Model
import UIKit

class LegendItemView: UIView {
    // MARK: - Subtypes
    struct ViewModel {
        var color: UIColor
        var description: String
        var percentageString: String
    }

    // MARK: - Properties: UI
    let colorView = UIView()
    let percentageLabel = UILabel()
    let descriptionLabel = UILabel()

    var colorViewRightConstraint: NSLayoutConstraint!

    // MARK: Model
    var viewModel: ViewModel? {
        didSet {
            colorView.backgroundColor = viewModel?.color
            percentageLabel.text = viewModel?.percentageString
            descriptionLabel.text = viewModel?.description
        }
    }

    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    override func layoutSubviews() {
        super.layoutSubviews()

        colorView.layer.cornerRadius = colorView.frame.width / 2
        colorViewRightConstraint.constant = -colorView.frame.width / 2

        percentageLabel.font = UIFont.systemFont(ofSize: percentageLabel.frame.height / 1.2, weight: .medium)
        descriptionLabel.font = UIFont.systemFont(ofSize: descriptionLabel.frame.height / 1.3, weight: .light)
    }

    private func setupView() {
        colorView.translatesAutoresizingMaskIntoConstraints = false
        percentageLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        colorView.layer.masksToBounds = true

        descriptionLabel.textAlignment = .left
        descriptionLabel.textColor = .black
        
        percentageLabel.textColor = .black

        addSubview(colorView)
        addSubview(percentageLabel)
        addSubview(descriptionLabel)

        colorViewRightConstraint = colorView.rightAnchor.constraint(equalTo: percentageLabel.leftAnchor, constant: 0)

        let constraints = [
            // Widths & Heights
            colorView.widthAnchor.constraint(equalTo: colorView.heightAnchor),
            colorView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.13),
            percentageLabel.heightAnchor.constraint(equalTo: colorView.heightAnchor, multiplier: 1.7),
            descriptionLabel.heightAnchor.constraint(equalTo: colorView.heightAnchor, multiplier: 1.3),

            // Vertical Layout
            percentageLabel.bottomAnchor.constraint(equalTo: centerYAnchor),
            colorView.centerYAnchor.constraint(equalTo: percentageLabel.centerYAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: percentageLabel.bottomAnchor),

            // Horizontal Layout
            colorView.leftAnchor.constraint(equalTo: leftAnchor),
            colorViewRightConstraint!,
            percentageLabel.rightAnchor.constraint(equalTo: rightAnchor),
            descriptionLabel.leftAnchor.constraint(equalTo: leftAnchor),
            descriptionLabel.rightAnchor.constraint(equalTo: rightAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
