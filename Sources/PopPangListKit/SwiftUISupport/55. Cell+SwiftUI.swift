//
//  Cell+SwiftUI.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import SwiftUI

private struct SwiftUIBindingItem<Item: Equatable>: Equatable {
    let value: Item
    let binding: Binding<Item>

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

/**
 Cell(
     id: item.id,
     item: item
 ) { item in
     VStack(alignment: .leading) {
         Text(item.title)
         Text(item.subtitle)
     }
 }
 */
// item이 변경되면 AnyComponent 비교와 DifferenceKit이 변경을 감지합니다.
extension Cell {
    @MainActor
    public init<Item: Equatable, Content: View>(
        id: some Hashable,
        item: Item,
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: (Item) -> Content
    ) {
        self.init(
            id: id,
            component: SwiftUIHostingComponent(
                item: item,
                layoutMode: layoutMode,
                content: content(item)
            )
        )
    }
}

// 입력 컨트롤은 부모 상태를 직접 읽고 쓸 수 있도록 Binding을 전달합니다.
extension Cell {
    @MainActor
    public init<Item: Equatable, Content: View>(
        id: some Hashable,
        item: Binding<Item>,
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: (Binding<Item>) -> Content
    ) {
        let bindingItem = SwiftUIBindingItem(
            value: item.wrappedValue,
            binding: item
        )

        self.init(
            id: id,
            component: SwiftUIHostingComponent(
                item: bindingItem,
                layoutMode: layoutMode,
                content: content(bindingItem.binding)
            )
        )
    }
}

// item 없이 SwiftUI 상태를 직접 캡처하는 convenience initializer입니다.
// 새 List snapshot마다 콘텐츠를 갱신합니다. 특정 값이 바뀔 때만 갱신하려면 item: initializer를 사용하세요.
extension Cell {
    @MainActor
    public init<Content: View>(
        id: some Hashable,
        layoutMode: ContentLayoutMode = .flexibleHeight(
            estimatedHeight: 44
        ),
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            id: id,
            component: SwiftUIHostingComponent(
                item: SwiftUIRefreshToken(),
                layoutMode: layoutMode,
                content: content()
            )
        )
    }
}
