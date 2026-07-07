//
//  AnyItemTests.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import UIKit
import Testing
@testable import PopPangListKit

/// `AnyItem`은 `Component.item`만 따로 꺼내서 `Equatable` 비교용으로 감싼 타입입니다.
///
/// 서로 다른 `Component`는 서로 다른 `Item` 타입을 가질 수 있습니다.
///
/// 예를 들어:
/// - `ProfileComponent.Item`
/// - `BannerComponent.Item`
///
/// 두 타입은 모두 `Equatable`이어도 직접 비교할 수 없습니다.
///
/// 하지만 `[AnyComponent]` 배열에서는 diffing 과정에서
/// 이전 Component의 item과 새로운 Component의 item을 비교해
/// UI를 다시 렌더링해야 하는지 판단해야 합니다.
///
/// `AnyItem`은 `Item`의 구체 타입을 숨기고,
/// `AnyItem`끼리 안전하게 비교할 수 있게 해줍니다.
///
/// - 타입이 같고 값도 같으면 `true`
/// - 타입이 같지만 값이 다르면 `false`
/// - 타입이 다르면 `false`
///
/// 즉, 서로 다른 Component가 섞인 리스트에서도
/// 크래시 없이 변경 여부를 판단하기 위해 사용합니다.
@Suite("AnyItem Tests")
struct AnyItemTests {

    @Test("같은 Component 타입, 같은 item이면 true")
    func sameComponentSameItem() {
        let lhs = AnyItem(component: MockComponent(item: .init(title: "A")))
        let rhs = AnyItem(component: MockComponent(item: .init(title: "A")))

        #expect(lhs == rhs)
    }

    @Test("같은 Component 타입, 다른 item이면 false")
    func sameComponentDifferentItem() {
        let lhs = AnyItem(component: MockComponent(item: .init(title: "A")))
        let rhs = AnyItem(component: MockComponent(item: .init(title: "B")))

        #expect(lhs != rhs)
    }

    @Test("다른 Component 타입이면 false")
    func differentComponentType() {
        let lhs = AnyItem(component: MockComponent(item: .init(title: "A")))
        let rhs = AnyItem(component: OtherMockComponent(item: .init(title: "A")))

        #expect(lhs != rhs)
    }
}

private struct MockComponent: Component {
    struct Item: Equatable {
        let title: String
    }

    let item: Item
    let layoutMode: ContentLayoutMode = .fitContainer

    func renderContent(coordinator: Void) -> UIView {
        UIView()
    }

    func render(in content: UIView, coordinator: Void) {}
}

private struct OtherMockComponent: Component {
    struct Item: Equatable {
        let title: String
    }

    let item: Item
    let layoutMode: ContentLayoutMode = .fitContainer

    func renderContent(coordinator: Void) -> UIView {
        UIView()
    }

    func render(in content: UIView, coordinator: Void) {}
}
