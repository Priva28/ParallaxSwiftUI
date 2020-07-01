import SwiftUI

extension View {
    func parallax(amount: CGFloat = 10) -> some View {
        ParallaxView(view: AnyView(self), amount: amount)
    }
}

/// A wrapper view to add a parallax effect to a SwiftUI view.
struct ParallaxView: View {
    
    /// The view to apply the parallax too.
    let view: AnyView
    
    /// The amount of the parallax effect to be applied.
    let amount: CGFloat
    
    var body: some View {
        /// Using geometry reader we can get the proposed width and height of the view normally. Then we can pass that to the view controller.
        GeometryReader { geometry in
            ParallaxRepresentable(view: view, width: geometry.size.width, height: geometry.size.height, amount: amount)
        }
    }
}

/// Converts SwiftUI view to UIKit controller.
struct ParallaxRepresentable: UIViewControllerRepresentable {
    
    let view: AnyView
    let width: CGFloat
    let height: CGFloat
    let amount: CGFloat

    func makeUIViewController(context: Context) -> ParallaxController {
        
        let controller = ParallaxController()
        
        let hostingController = UIHostingController(rootView: view)
        
        controller.viewWidth = width
        controller.viewHeight = height
        controller.amount = amount
        controller.viewToChange = hostingController
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ParallaxController, context: Context) {
        uiViewController.viewWidth = width
        uiViewController.viewHeight = height
        uiViewController.updateView()
    }
}

/// View controller that adds parallax effect to view of another view controller.
class ParallaxController: UIViewController {
    
    var viewToChange: UIViewController?
    var viewWidth: CGFloat = 0
    var viewHeight: CGFloat = 0
    var amount: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add SwiftUI view to view controller
        addChild(viewToChange!)
        view.addSubview(viewToChange!.view)
        viewToChange!.didMove(toParent: self)
    
        // Set frame
        viewToChange!.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = viewToChange!.view.frame
        
        // Clear background colour
        viewToChange!.view.backgroundColor = .clear
    }
    
    func updateView() {
        viewToChange!.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        view.frame = viewToChange!.view.frame
    }
    
    let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
    let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
    let group = UIMotionEffectGroup()
    
    override func viewWillLayoutSubviews() {
        
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        group.motionEffects = [horizontal, vertical]
        viewToChange!.view.addMotionEffect(group)
    }

}

