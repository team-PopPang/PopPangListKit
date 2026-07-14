//
//  SwiftUIHostingComponent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import Foundation
import SwiftUI

/// 외부 SwiftUI 상태를 캡처하는 콘텐츠가 새 List snapshot에서 다시 렌더링되도록 합니다.
///
/// `View`는 일반적으로 Equatable이 아니므로, `item:` 없이 선언한 SwiftUI Cell과
/// supplementary view는 이 토큰으로 콘텐츠 변경을 DifferenceKit에 알립니다.
struct SwiftUIRefreshToken: Equatable {
    private let value = UUID()
}

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
