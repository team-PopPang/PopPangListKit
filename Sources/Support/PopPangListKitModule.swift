import Foundation

public enum PopPangListKitModule {}

import SwiftUI

struct SampleView: View {
    var body: some View {
        VStack {
            Text("SampleView")
        }
    }
}

// SwiftUI View → UIViewController
let viewController = UIHostingController(rootView: SampleView())

// SwiftUI View → UIView
let uiView = viewController.view!
