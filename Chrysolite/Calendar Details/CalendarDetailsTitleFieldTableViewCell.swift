import UIKit

class CalendarDetailsTitleFieldTableViewCell: UITableViewCell, IdentifiableView {
    static let identifier = "CalendarDetailsTitleFieldTableViewCell"
    
    var label: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, design: .rounded)
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            label.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: CalendarDetailsTableViewItem) {
        label.text = item.title
    }
}
