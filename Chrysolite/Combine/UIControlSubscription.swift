import UIKit
import Combine

class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control

        control.addTarget(self, action: #selector(handleEvent), for: event)
    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
        subscriber = nil
    }

    @objc private func handleEvent() {
        _ = subscriber?.receive(control)
    }
}
