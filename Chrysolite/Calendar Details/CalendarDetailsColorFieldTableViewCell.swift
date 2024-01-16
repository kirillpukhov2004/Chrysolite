import UIKit

class CalendarDetailsColorFieldTableViewCell: UITableViewCell, IdentifiableView {
    static let identifier = "CalendarDetailsColorFieldTableViewCell"

    var titleLabel: UILabel!

    var colorIndicator: UIView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel = UILabel()
        titleLabel.text = "Color"
        contentView.addSubview(titleLabel)

        colorIndicator = UIView()
        colorIndicator.layer.cornerRadius = Constants.colorIndicatorDimension / 2
        contentView.addSubview(colorIndicator)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: colorIndicator.leadingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])

        colorIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorIndicator.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            colorIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorIndicator.heightAnchor.constraint(equalToConstant: Constants.colorIndicatorDimension),
            colorIndicator.widthAnchor.constraint(equalToConstant: Constants.colorIndicatorDimension),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: CalendarDetailsTableViewCellModel) {
        colorIndicator.backgroundColor = item.calendarIndicatorColor
    }

    private enum Constants {
        static let colorIndicatorDimension: CGFloat = 17
    }
}
