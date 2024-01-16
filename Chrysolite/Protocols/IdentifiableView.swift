import UIKit

protocol IdentifiableView: UIView {
    static var identifier: String { get }
}
