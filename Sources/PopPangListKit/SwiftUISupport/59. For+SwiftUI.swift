//
//  For+SwiftUI.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/14/26.
//

import SwiftUI

/// SwiftUI 데이터를 반복해 `Cell`로 만드는 DSL입니다.
///
/// `For`는 각 Element를 기존 `Cell(id:item:)`으로 변환합니다.
/// Element는 변경 감지에 사용되고, `layoutMode`는 생성되는 모든 Cell에 적용됩니다.
///
/// ```swift
/// Section(id: "popups") {
///     For(popups, id: \.id) { popup in
///         PopupRow(popup: popup)
///     }
///     .didSelect { popup in
///         print(popup.id)
///     }
/// }
/// ```
@MainActor
public struct For<Data, ID, Content>
where Data: RandomAccessCollection,
      Data.Element: Equatable,
      ID: Hashable,
      Content: View {

    private let data: Data
    private let id: KeyPath<Data.Element, ID>
    private let layoutMode: ContentLayoutMode
    private let content: (Data.Element) -> Content
    private var didSelectHandler: ((Data.Element) -> Void)?

    /// 데이터를 반복해 SwiftUI Cell을 만듭니다.
    ///
    /// - Parameters:
    ///   - data: Cell로 표시할 `Equatable` 데이터 컬렉션입니다.
    ///   - id: 각 Cell을 식별할 Element의 KeyPath입니다.
    ///   - layoutMode: 생성되는 모든 Cell에 적용할 크기 규칙입니다.
    ///   - content: Element를 SwiftUI View로 표현하는 클로저입니다.
    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44),
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.layoutMode = layoutMode
        self.content = content
    }

    /// 생성되는 Cell의 선택 이벤트를 Element와 함께 처리합니다.
    ///
    /// 단일 `Cell`의 `didSelect`와 달리 collection view EventContext가 아니라
    /// `For`에 전달한 원본 Element를 제공합니다.
    @discardableResult
    public func didSelect(
        _ handler: @escaping (Data.Element) -> Void
    ) -> Self {
        var copy = self
        copy.didSelectHandler = handler
        return copy
    }

    var cells: [Cell] {
        data.map { element in
            let cell = Cell(
                id: element[keyPath: id],
                item: element,
                layoutMode: layoutMode,
                content: content
            )

            guard let didSelectHandler else {
                return cell
            }

            return cell.didSelect { _ in
                didSelectHandler(element)
            }
        }
    }
}

extension CellsBuilder {

    /// SwiftUI `For` 표현식을 Cell 배열로 변환합니다.
    @MainActor
    public static func buildExpression<Data, ID, Content>(
        _ expression: For<Data, ID, Content>
    ) -> [Cell]
    where Data: RandomAccessCollection,
          Data.Element: Equatable,
          ID: Hashable,
          Content: View {
        expression.cells
    }
}
