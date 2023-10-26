import UIKit
import Combine

struct UIControlPublisher<Control: UIControl>: Publisher {
    typealias Output = Control
    typealias Failure = Never

    let control: Control
    let event: UIControl.Event

    init(control: Control, event: UIControl.Event) {
        self.control = control
        self.event = event
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, event: event)
        subscriber.receive(subscription: subscription)
    }
}

