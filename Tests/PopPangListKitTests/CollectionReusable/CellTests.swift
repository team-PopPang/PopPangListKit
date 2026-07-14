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

    // MARK: - SwiftUI For
    @Test("For는 데이터마다 Cell을 만들고 id를 사용한다")
    @MainActor
    func swiftUIForMakesCellsWithElementIDs() {
        let items = [
            ForItem(id: "first", title: "첫 번째"),
            ForItem(id: "second", title: "두 번째"),
        ]

        let section = Section(id: "items") {
            For(items, id: \.id) { item in
                Text(item.title)
            }
        }

        #expect(section.cells.map(\.id) == ["first", "second"])
    }

    @Test("For는 Element가 변경되면 같은 id의 Cell 변경을 감지한다")
    @MainActor
    func swiftUIForDetectsElementChanges() {
        let before = Section(id: "items") {
            For([ForItem(id: "first", title: "이전")], id: \.id) { item in
                Text(item.title)
            }
        }
        let after = Section(id: "items") {
            For([ForItem(id: "first", title: "이후")], id: \.id) { item in
                Text(item.title)
            }
        }

        #expect(before.cells[0].differenceIdentifier == after.cells[0].differenceIdentifier)
        #expect(!before.cells[0].isContentEqual(to: after.cells[0]))
    }

    @Test("For의 layoutMode modifier는 생성되는 모든 Cell에 적용된다")
    @MainActor
    func swiftUIForAppliesLayoutModeToAllCells() {
        let layoutMode = ContentLayoutMode.fitContent(
            estimatedSize: .init(width: 194, height: 271)
        )
        let section = Section(id: "items") {
            For(
                [
                    ForItem(id: "first", title: "첫 번째"),
                    ForItem(id: "second", title: "두 번째"),
                ],
                id: \.id
            ) { item in
                Text(item.title)
            }
            .layoutMode(layoutMode)
        }

        #expect(
            section.cells.allSatisfy {
                $0.component.layoutMode == layoutMode
            }
        )
    }

    @Test("For의 didSelect는 선택된 원본 Element를 전달한다")
    @MainActor
    func swiftUIForPassesSelectedElement() {
        let item = ForItem(id: "first", title: "첫 번째")
        var selectedID: String?

        let section = Section(id: "items") {
            For([item], id: \.id) { item in
                Text(item.title)
            }
            .didSelect { selectedItem in
                selectedID = selectedItem.id
            }
        }

        guard let event = section.cells[0].event(for: DidSelectEvent.self) else {
            Issue.record("For가 didSelect 이벤트를 등록해야 합니다.")
            return
        }

        event.handler(
            .init(
                indexPath: .init(item: 0, section: 0),
                anyComponent: section.cells[0].component
            )
        )

        #expect(selectedID == item.id)
    }
}

private struct ForItem: Equatable {
    let id: String
    let title: String
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
