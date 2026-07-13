//
//  HostingConfigurationView.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import SwiftUI

@MainActor
final class HostingContentView<Content: View>: UIView {
    
    private let hostingController: UIHostingController<Content>
    
    var rootView: Content {
        get { hostingController.rootView }
        set { hostingController.rootView = newValue }
    }

    init(rootView: Content) {
        hostingController = UIHostingController(rootView: rootView)
        super.init(frame: .zero)
        
        backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        hostingController.sizeThatFits(in: CGSize(
            width: size.width,
            height: .greatestFiniteMagnitude
        ))
    }
}
