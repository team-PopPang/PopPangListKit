import SwiftUI
import UIKit

extension SupplementaryView {
    /// 기존 Component 기반 supplementary 렌더링 경로에 SwiftUI View를 연결합니다.
    public static func swiftUI<Item: Equatable, Content: View>(
        kind: String,
        item: Item,
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        alignment: NSRectAlignment = .top,
        @ViewBuilder content: (Item) -> Content
    ) -> Self {
        Self(
            kind: kind,
            component: SwiftUIHostingComponent(
                item: item,
                layoutMode: layoutMode,
                content: content(item)
            ),
            alignment: alignment
        )
    }

    public static func header<Item: Equatable, Content: View>(
        item: Item,
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: (Item) -> Content
    ) -> Self {
        swiftUI(
            kind: UICollectionView.elementKindSectionHeader,
            item: item,
            layoutMode: layoutMode,
            alignment: .top,
            content: content
        )
    }

    public static func footer<Item: Equatable, Content: View>(
        item: Item,
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: (Item) -> Content
    ) -> Self {
        swiftUI(
            kind: UICollectionView.elementKindSectionFooter,
            item: item,
            layoutMode: layoutMode,
            alignment: .bottom,
            content: content
        )
    }
}

extension Section {
    @MainActor
    public func withHeader<Item: Equatable, Content: View>(
        item: Item,
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: (Item) -> Content
    ) -> Self {
        var copy = self
        copy.header = .header(
            item: item,
            layoutMode: layoutMode,
            content: content
        )
        return copy
    }

    @MainActor
    public func withFooter<Item: Equatable, Content: View>(
        item: Item,
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: (Item) -> Content
    ) -> Self {
        var copy = self
        copy.footer = .footer(
            item: item,
            layoutMode: layoutMode,
            content: content
        )
        return copy
    }
}
