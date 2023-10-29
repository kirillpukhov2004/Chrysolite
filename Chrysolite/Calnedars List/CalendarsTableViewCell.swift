import UIKit

class CalendarsTableViewCell: UITableViewCell, IdentifiableView {
    static let identifier = "CalendarsTableViewCell"

    var colorIndicatorView: UIView!

    var titleLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureViews()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        colorIndicatorView = UIView()
        colorIndicatorView.layer.cornerRadius = Constants.colorIndicatorDimension / 2

        titleLabel = UILabel()

        if let fontDescriptor = UIFont.systemFont(ofSize: 17, weight: .regular).fontDescriptor.withDesign(.rounded) {
            titleLabel.font = UIFont(descriptor: fontDescriptor, size: 17)
        }
    }

    private func addSubviews() {
        contentView.addSubview(colorIndicatorView)

        contentView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        colorIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorIndicatorView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            colorIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorIndicatorView.heightAnchor.constraint(equalToConstant: Constants.colorIndicatorDimension),
            colorIndicatorView.widthAnchor.constraint(equalToConstant: Constants.colorIndicatorDimension),
        ])

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: colorIndicatorView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    func configureCell(for item: CalendarsTableViewCellModel) {
        titleLabel.text = item.title

        colorIndicatorView.backgroundColor = item.color
    }

    private enum Constants {
        static let colorIndicatorDimension: CGFloat = 15
    }
}
