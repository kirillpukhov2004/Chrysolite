import UIKit

class CustomPresentationController: UIPresentationController {
    private var dimmingView: UIView!
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        let safeAreaInsets = containerView.safeAreaInsets
        let safeAreaTotalVerticalInsets = safeAreaInsets.top + safeAreaInsets.bottom
        
        let size = CGSize(width: containerView.frame.width - 16 * 2,
                          height: (containerView.frame.height - safeAreaTotalVerticalInsets) - 16 * 2)
        
        let originY = (containerView.bounds.height - size.height + safeAreaTotalVerticalInsets) / 2
        let origin = CGPoint(x: (containerView.bounds.width - size.width) / 2,
                             y: originY)

        return CGRect(origin: origin, size: size)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView,
              let presentedView = presentedView,
              let transitionCoordinator = presentingViewController.transitionCoordinator
        else { return }
        
        dimmingView = UIView()
        dimmingView.frame = containerView.bounds
        dimmingView.autoresizingMask = [
            .flexibleLeftMargin,
            .flexibleRightMargin,
            .flexibleTopMargin,
            .flexibleBottomMargin
        ]
        dimmingView.backgroundColor = .black.withAlphaComponent(0.75)
        containerView.addSubview(dimmingView)
        
        dimmingView.alpha = 0.0
        transitionCoordinator.animate { [weak self] _ in
            self?.dimmingView.alpha = 1.0
        }
        
        presentedView.layer.cornerRadius = 10
        
    }
    
    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentingViewController.transitionCoordinator else { return }
        
        dimmingView.alpha = 1.0
        transitionCoordinator.animate { [weak self] _ in
            self?.dimmingView.alpha = 0.0
        }
    }
}
