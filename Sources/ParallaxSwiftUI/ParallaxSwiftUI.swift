import SwiftUI

extension View {
    public func parallax(amount: CGFloat = 10, direction: ParallaxDirection = .both) -> some View {
        ParallaxView(
            view: AnyView(self),
            amount: amount,
            direction: direction
        )
    }
    public func parallax(minHorizontal: CGFloat = -10, maxHorizontal: CGFloat = 10, minVertical: CGFloat = -10, maxVertical: CGFloat = 10, direction: ParallaxDirection = .both) -> some View {
        ParallaxView(
            view: AnyView(self),
            minHorizontal: minHorizontal,
            maxHorizontal: maxHorizontal,
            minVertical: minVertical,
            maxVertical: maxVertical,
            direction: direction
        )
    }
}

public enum ParallaxDirection {
    case vertical
    case horizontal
    case both
}

/// A wrapper view to add a parallax effect to a SwiftUI view.
struct ParallaxView: View {
    
    /// The view to apply the parallax too.
    let view: AnyView
    
    /// The amount of the parallax effect to be applied.
    let amount: CGFloat?
    
    let minHorizontal: CGFloat
    let maxHorizontal: CGFloat
    
    let minVertical: CGFloat
    let maxVertical: CGFloat
    
    let direction: ParallaxDirection
    
    init(view: AnyView, minHorizontal: CGFloat = -10, maxHorizontal: CGFloat = 10, minVertical: CGFloat = -10, maxVertical: CGFloat = 10, amount: CGFloat? = nil, direction: ParallaxDirection) {
        self.view = view
        self.direction = direction
        
        if amount == nil {
            self.amount = nil
            self.minHorizontal = minHorizontal
            self.maxHorizontal = maxHorizontal
            self.minVertical = minVertical
            self.maxVertical = maxVertical
        } else {
            self.amount = amount
            self.minHorizontal = -amount!
            self.maxHorizontal = amount!
            self.minVertical = -amount!
            self.maxVertical = amount!
        }
    }
    
    var body: some View {
        /// Using geometry reader we can get the proposed width and height of the view normally. Then we can pass that to the view controller.
        GeometryReader { geometry in
            ParallaxRepresentable(view: view, width: geometry.frame(in: .local).size.width, height: geometry.frame(in: .local).size.height, minHorizontal: minHorizontal, maxHorizontal: maxHorizontal, minVertical: minVertical, maxVertical: maxVertical, direction: direction)
        }
    }
}

/// Converts SwiftUI view to UIKit controller.
struct ParallaxRepresentable: UIViewControllerRepresentable {
    
    let view: AnyView
    let width: CGFloat
    let height: CGFloat
    
    let minHorizontal: CGFloat
    let maxHorizontal: CGFloat
    
    let minVertical: CGFloat
    let maxVertical: CGFloat
    
    let direction: ParallaxDirection

    func makeUIViewController(context: Context) -> ParallaxController {
        
        let controller = ParallaxController()
        
        let hostingController = UIHostingController(rootView: view)
        
        controller.viewWidth = width
        controller.viewHeight = height
        
        controller.minHorizontal = minHorizontal
        controller.maxHorizontal = maxHorizontal
        controller.minVertical = minVertical
        controller.maxVertical = maxVertical
        
        controller.direction = direction
        
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
    
    var minHorizontal: CGFloat = -10
    var maxHorizontal: CGFloat = 10
    
    var minVertical: CGFloat = -10
    var maxVertical: CGFloat = 10
    
    var direction: ParallaxDirection = .both
    
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
        
        horizontal.minimumRelativeValue = minHorizontal
        horizontal.maximumRelativeValue = maxHorizontal

        vertical.minimumRelativeValue = minVertical
        vertical.maximumRelativeValue = maxVertical

        if direction == .horizontal {
            group.motionEffects = [horizontal]
        } else if direction == .vertical {
            group.motionEffects = [vertical]
        } else {
            group.motionEffects = [horizontal, vertical]
        }
        
        viewToChange!.view.addMotionEffect(group)
    }

}

