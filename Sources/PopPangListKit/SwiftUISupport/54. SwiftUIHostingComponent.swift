//
//  SwiftUIHostingComponent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import SwiftUI

struct SwiftUIHostingComponent<Item: Equatable, Content: View>: Component {
    let item: Item
    let layoutMode: ContentLayoutMode
    let content: Content
    
    func renderContent(
        coordinator: Void
    ) -> HostingContentView<Content> {
        HostingContentView(rootView: content)
    }
    
    func render(
        in contentView: HostingContentView<Content>,
        coordinator: Void
    ) {
        contentView.rootView = content
    }
}
