//
//  Cell+SwiftUI.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import SwiftUI

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

// 정적 콘텐츠용 convenience initializer입니다
// 정적 initializer는 동일한 ID에서 외부 값만 바뀌면 diff가 변경을 감지하지 못할 수 있습니다.
// 동적 셀은 item: initializer를 사용하는 게 안전합니다.
extension Cell {
    @MainActor
    public init<Content: View>(
        id: some Hashable,
        layoutMode: ContentLayoutMode = .flexibleHeight(
            estimatedHeight: 44
        ),
        @ViewBuilder content: () -> Content
    ) {
        let identity = AnyHashable(id)

        self.init(
            id: identity,
            component: SwiftUIHostingComponent(
                item: identity,
                layoutMode: layoutMode,
                content: content()
            )
        )
    }
}
