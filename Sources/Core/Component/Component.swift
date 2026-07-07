//
//  Component.swift
//  PopPangListKitDemo
//
//  Created by 김동현 on 7/7/26.
//

import UIKit

public protocol Component {
    associatedtype Item: Equatable
    associatedtype Content: UIView
    associatedtype Coordinator = Void
    
    var item: Item { get }
    var reuseIdentifier: String { get }
    var layoutMode: ContentLayoutMode { get }
    
    @MainActor
    func renderContent(coordinator: Coordinator) -> Content
    
    @MainActor
    func render(in content: Content, coordinator: Coordinator)
    
    @MainActor
    func layout(content: Content, in container: UIView)
    
    @MainActor
    func makeCoordinator() -> Coordinator
}

extension Component {
    public var reuseIdentifier: String {
        return String(reflecting: Self.self)
    }
}

extension Component where Coordinator == Void {
    @MainActor
    public func makeCoordinator() -> Coordinator {
        return ()
    }
}

extension Component where Content: UIView {
    @MainActor
    public func layout(
        content: Content,
        in container: UIView
    ) {
        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: container.topAnchor),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
}
