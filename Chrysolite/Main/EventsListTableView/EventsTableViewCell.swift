import UIKit

class EventsListTableViewCell: UITableViewCell, IdentifiableView {
    static let identifier = "EventsListTableViewCell"

    var stackView: UIStackView!
    
    var calendarColorIndicatorView: UIView!
    
    var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        contentView.addSubview(stackView)
        
        calendarColorIndicatorView = UIView()
        calendarColorIndicatorView.layer.cornerRadius = Constants.calendarColorIndicatorDimension / 2
        stackView.addArrangedSubview(calendarColorIndicatorView)
        stackView.setCustomSpacing(7, after: calendarColorIndicatorView)

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17, design: .rounded)
        titleLabel.textAlignment = .left
        stackView.addArrangedSubview(titleLabel)
        
        let leftConstraint = NSLayoutConstraint(item: stackView!, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1, constant: 16)
        leftConstraint.priority = .init(999)
        let rightConstraint = NSLayoutConstraint(item: stackView!, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1, constant: -16)
        rightConstraint.priority = .init(999)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftConstraint,
            rightConstraint,
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
        
        NSLayoutConstraint.activate([
            calendarColorIndicatorView.widthAnchor.constraint(equalToConstant: Constants.calendarColorIndicatorDimension),
            calendarColorIndicatorView.heightAnchor.constraint(equalTo: calendarColorIndicatorView.widthAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: EventsListTableViewCellModel) {
        calendarColorIndicatorView.backgroundColor = item.calendarColor

        titleLabel.text = item.title
    }

    private enum Constants {
        static let calendarColorIndicatorDimension: CGFloat = 10
    }
}
