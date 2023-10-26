import UIKit

class CalendarDetailsSourceFieldTableViewCell: UITableViewCell {
    static let identifier = "CalendarDetailsSourceFieldTableViewCell"

    var sourceTypeImageView: UIImageView!

    var label: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        sourceTypeImageView = UIImageView()
        sourceTypeImageView.contentMode = .scaleAspectFit
        contentView.addSubview(sourceTypeImageView)

        label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, design: .rounded)
        contentView.addSubview(label)
        
        sourceTypeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sourceTypeImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            sourceTypeImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            sourceTypeImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            sourceTypeImageView.widthAnchor.constraint(equalTo: sourceTypeImageView.heightAnchor),
        ])

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: sourceTypeImageView.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: CalendarDetailsTableViewItem) {
        let image: UIImage
        switch item.sourceType {
        case .local:
            image = UIImage(systemName: "house")!
        case .external:
            image = UIImage(systemName: "globe")!
        case .birthdays:
            image = UIImage(systemName: "birthday.cake")!
        }

        sourceTypeImageView.image = image

        label.text = item.sourceType.rawValue
    }
}
