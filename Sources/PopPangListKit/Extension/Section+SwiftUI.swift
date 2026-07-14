import SwiftUI
import UIKit

extension SupplementaryView {
    /// supplementary view의 전체 폭 배경색을 설정합니다.
    @MainActor
    public func background(_ color: UIColor?) -> Self {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

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

    /// `item` 없이 SwiftUI supplementary view를 연결합니다.
    ///
    /// 새 List snapshot이 적용될 때 closure가 캡처한 SwiftUI 상태를 반영합니다.
    /// 특정 값이 바뀔 때만 갱신하려면 `item:` overload를 사용하세요.
    public static func swiftUI<Content: View>(
        kind: String,
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        alignment: NSRectAlignment = .top,
        @ViewBuilder content: () -> Content
    ) -> Self {
        swiftUI(
            kind: kind,
            item: SwiftUIRefreshToken(),
            layoutMode: layoutMode,
            alignment: alignment
        ) { _ in
            content()
        }
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

    /// `item` 없이 SwiftUI Section Header를 선언합니다.
    public static func header<Content: View>(
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: () -> Content
    ) -> Self {
        swiftUI(
            kind: UICollectionView.elementKindSectionHeader,
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

    /// `item` 없이 SwiftUI Section Footer를 선언합니다.
    public static func footer<Content: View>(
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: () -> Content
    ) -> Self {
        swiftUI(
            kind: UICollectionView.elementKindSectionFooter,
            layoutMode: layoutMode,
            alignment: .bottom,
            content: content
        )
    }
}

extension Section {
    /// Header의 배경을 collection view 전체 폭으로 확장합니다.
    ///
    /// Header 콘텐츠와 Cell에 적용된 section inset은 유지합니다. 일반 Header와 고정
    /// Header 모두에서 section inset 바깥을 배경으로 덮을 때 사용하세요.
    @MainActor
    public func headerBackground(_ color: UIColor?) -> Self {
        var copy = self

        guard let header else {
            assertionFailure("Please declare the header first using [withHeader]")
            return copy
        }

        copy.header = header.background(color)
        return copy
    }

    /// Footer의 배경을 collection view 전체 폭으로 확장합니다.
    ///
    /// Footer 콘텐츠와 Cell에 적용된 section inset은 유지합니다.
    @MainActor
    public func footerBackground(_ color: UIColor?) -> Self {
        var copy = self

        guard let footer else {
            assertionFailure("Please declare the footer first using [withFooter]")
            return copy
        }

        copy.footer = footer.background(color)
        return copy
    }

    /// `item` 없이 SwiftUI Section Header를 선언합니다.
    ///
    /// Header가 외부 SwiftUI 상태를 직접 캡처할 때 사용합니다.
    @MainActor
    public func withHeader<Content: View>(
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: () -> Content
    ) -> Self {
        var copy = self
        copy.header = .header(
            layoutMode: layoutMode,
            content: content
        )
        return copy
    }

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

    /// `item` 없이 SwiftUI Section Footer를 선언합니다.
    ///
    /// Footer가 외부 SwiftUI 상태를 직접 캡처할 때 사용합니다.
    @MainActor
    public func withFooter<Content: View>(
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: () -> Content
    ) -> Self {
        var copy = self
        copy.footer = .footer(
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
