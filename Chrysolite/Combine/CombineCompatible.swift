import UIKit

protocol CombineCompatible {}

extension CombineCompatible where Self: UIControl {
    func publisher(for event: UIControl.Event) -> UIControlPublisher<Self> {
        UIControlPublisher(control: self, event: event)
    }
}
