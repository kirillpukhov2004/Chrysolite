import UIKit

class EventsTableViewHeaderView: UITableViewHeaderFooterView, IdentifiableView {
    static let identifier = "EventsTableViewHeaderView"
    
    private var weekDayLabel: UILabel!
    private var dateLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        weekDayLabel = UILabel()
        weekDayLabel.numberOfLines = 0
        weekDayLabel.font = .systemFont(ofSize: 17, weight: .bold, design: .rounded)
        contentView.addSubview(weekDayLabel)
        
        dateLabel = UILabel()
        dateLabel.numberOfLines = 0
        dateLabel.font = .systemFont(ofSize: 14)
        contentView.addSubview(dateLabel)
        
        weekDayLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            weekDayLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            weekDayLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            weekDayLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: weekDayLabel.trailingAnchor, constant: 5),
            dateLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with section: EventsTableViewHeaderModel) {
        weekDayLabel.text = section.weekDayText
        dateLabel.text = section.dateLabelText
    }
}
