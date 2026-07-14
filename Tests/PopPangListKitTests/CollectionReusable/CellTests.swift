//
//  CellTests.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import UIKit
import SwiftUI
import Testing
import DifferenceKit
@testable import PopPangListKit

@Suite("Cell Tests")
struct CellTests {

    @Test("Cell은 전달받은 id를 그대로 가진다")
    func keepsID() {
        let cell = Cell(
            id: "profile-1",
            component: MockComponent(item: .init(title: "A"))
        )

        #expect(cell.id == AnyHashable("profile-1"))
    }

    // MARK: - Equatable
    @Test("Equatable: 같은 id와 같은 component면 같다")
    func equatable_sameIDAndSameComponent() {
        let lhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )
        let rhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )

        #expect(lhs == rhs)
    }

    @Test("Equatable: 같은 id라도 component item이 다르면 다르다")
    func equatable_sameIDDifferentComponent() {
        let lhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )
        let rhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "B"))
        )

        #expect(lhs != rhs)
    }

    @Test("Equatable: component가 같아도 id가 다르면 다르다")
    func equatable_differentIDSameComponent() {
        let lhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )
        let rhs = Cell(
            id: "cell-2",
            component: MockComponent(item: .init(title: "A"))
        )

        #expect(lhs != rhs)
    }

    @Test("Equatable: 같은 id와 item이어도 component 타입이 다르면 다르다")
    func equatable_sameIDDifferentComponentType() {
        let item = MockComponent.Item(title: "A")
        let lhs = Cell(
            id: "cell-1",
            component: MockComponent(item: item)
        )
        let rhs = Cell(
            id: "cell-1",
            component: OtherMockComponent(item: item)
        )

        #expect(lhs != rhs)
    }

    // MARK: - Hashable
    @Test("Hashable: hash는 id 기준이다")
    func hashable_hashUsesID() {
        let lhs = Cell(
            id: "same-id",
            component: MockComponent(item: .init(title: "A"))
        )
        let rhs = Cell(
            id: "same-id",
            component: MockComponent(item: .init(title: "B"))
        )

        #expect(lhs.hashValue == rhs.hashValue)
    }

    @Test("Hashable: 같은 id면 Set에서 중복 제거된다")
    func hashable_sameIDRemovedInSet() {
        let lhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )
        let rhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )

        let set: Set<Cell> = [lhs, rhs]

        #expect(set.count == 1)
    }

    @Test("Hashable: 다른 id면 Set에서 각각 유지된다")
    func hashable_differentIDKeptInSet() {
        let lhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )
        let rhs = Cell(
            id: "cell-2",
            component: MockComponent(item: .init(title: "A"))
        )

        let set: Set<Cell> = [lhs, rhs]

        #expect(set.count == 2)
    }

    // MARK: - Differentiable
    @Test("Differentiable: differenceIdentifier는 id를 반환한다")
    func differentiable_differenceIdentifierUsesID() {
        let cell = Cell(
            id: 100,
            component: MockComponent(item: .init(title: "A"))
        )

        #expect(cell.differenceIdentifier == AnyHashable(100))
    }

    @Test("Differentiable: isContentEqual은 id와 component가 같으면 true")
    func differentiable_contentEqual() {
        let lhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )
        let rhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )

        #expect(lhs.isContentEqual(to: rhs))
    }

    @Test("Differentiable: isContentEqual은 component가 다르면 false")
    func differentiable_contentNotEqualWhenComponentChanged() {
        let lhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "A"))
        )
        let rhs = Cell(
            id: "cell-1",
            component: MockComponent(item: .init(title: "B"))
        )

        #expect(!lhs.isContentEqual(to: rhs))
    }

    @Test("item 없는 SwiftUI Cell은 새 snapshot에서 콘텐츠를 갱신한다")
    @MainActor
    func staticSwiftUICellRefreshesCapturedState() {
        let first = Cell(id: "greeting") {
            Text("안녕하세요")
        }
        let updated = Cell(id: "greeting") {
            Text("반가워요")
        }

        #expect(first.id == updated.id)
        #expect(first != updated)
    }
}

private struct MockComponent: Component {
    struct Item: Equatable {
        let title: String
    }

    let item: Item
    let layoutMode: ContentLayoutMode = .fitContainer

    @MainActor
    func renderContent(coordinator: Void) -> UIView {
        UIView()
    }

    @MainActor
    func render(in content: UIView, coordinator: Void) {}
}

private struct OtherMockComponent: Component {
    let item: MockComponent.Item
    let layoutMode: ContentLayoutMode = .fitContainer

    @MainActor
    func renderContent(coordinator: Void) -> UIView {
        UIView()
    }

    @MainActor
    func render(in content: UIView, coordinator: Void) {}
}
