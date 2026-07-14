//
//  SectionTests.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit
import SwiftUI
import Testing
import DifferenceKit
@testable import PopPangListKit

@Suite("Section Tests")
struct SectionTests {

    // MARK: - Equatable
    @Test("Equatable: 같은 id면 같다")
    func equatable_sameID() {
        let lhs = Section(id: "section-1", cells: [])
        let rhs = Section(id: "section-1", cells: [])

        #expect(lhs == rhs)
    }

    @Test("Equatable: id가 다르면 다르다")
    func equatable_differentID() {
        let lhs = Section(id: "section-1", cells: [])
        let rhs = Section(id: "section-2", cells: [])

        #expect(lhs != rhs)
    }

    @Test("Equatable: cells가 달라도 id, header, footer가 같으면 같다")
    func equatable_ignoresCells() {
        let lhs = Section(
            id: "section-1",
            cells: [makeCell(id: "cell-1", title: "A")]
        )

        let rhs = Section(
            id: "section-1",
            cells: [makeCell(id: "cell-2", title: "B")]
        )

        #expect(lhs == rhs)
    }

    // MARK: - Hashable
    @Test("Hashable: 같은 id면 같은 hashValue를 가진다")
    func hashable_sameIDSameHashValue() {
        let lhs = Section(
            id: "same-id",
            cells: [makeCell(id: "cell-1", title: "A")]
        )

        let rhs = Section(
            id: "same-id",
            cells: [makeCell(id: "cell-2", title: "B")]
        )

        #expect(lhs.hashValue == rhs.hashValue)
    }

    @Test("Hashable: 같은 id면 Set에서 중복 제거된다")
    func hashable_sameIDRemovedInSet() {
        let lhs = Section(id: "section-1", cells: [])
        let rhs = Section(id: "section-1", cells: [])

        let set: Set<PopPangListKit.Section> = [lhs, rhs]

        #expect(set.count == 1)
    }

    @Test("Hashable: 다른 id면 Set에서 각각 유지된다")
    func hashable_differentIDKeptInSet() {
        let lhs = Section(id: "section-1", cells: [])
        let rhs = Section(id: "section-2", cells: [])

        let set: Set<PopPangListKit.Section> = [lhs, rhs]

        #expect(set.count == 2)
    }

    // MARK: - DifferentiableSection
    @Test("DifferentiableSection: differenceIdentifier는 id를 반환한다")
    func differentiable_differenceIdentifierUsesID() {
        let section = Section(id: 100, cells: [])

        #expect(section.differenceIdentifier == AnyHashable(100))
    }

    @Test("DifferentiableSection: elements는 cells를 반환한다")
    func differentiable_elementsReturnsCells() {
        let cells = [
            makeCell(id: "cell-1", title: "A"),
            makeCell(id: "cell-2", title: "B")
        ]

        let section = Section(id: "section-1", cells: cells)

        #expect(section.elements == cells)
    }

    @Test("DifferentiableSection: init(source:elements:)는 cells만 교체한다")
    func differentiable_initSourceElementsReplacesOnlyCells() {
        let source = Section(
            id: "section-1",
            cells: [makeCell(id: "cell-1", title: "A")]
        )

        let newCells = [
            makeCell(id: "cell-2", title: "B"),
            makeCell(id: "cell-3", title: "C")
        ]

        let newSection = Section(
            source: source,
            elements: newCells
        )

        #expect(newSection.id == source.id)
        #expect(newSection.cells == newCells)
    }

    @Test("DifferentiableSection: isContentEqual은 == 결과를 따른다")
    func differentiable_isContentEqualUsesEquatable() {
        let lhs = Section(
            id: "section-1",
            cells: [makeCell(id: "cell-1", title: "A")]
        )

        let rhs = Section(
            id: "section-1",
            cells: [makeCell(id: "cell-2", title: "B")]
        )

        #expect(lhs.isContentEqual(to: rhs))
    }

    @Test("DifferentiableSection: id가 다르면 isContentEqual은 false")
    func differentiable_isContentEqualFalseWhenIDDifferent() {
        let lhs = Section(id: "section-1", cells: [])
        let rhs = Section(id: "section-2", cells: [])

        #expect(!lhs.isContentEqual(to: rhs))
    }

    @Test("item 없는 SwiftUI Header와 Footer를 Section modifier로 선언할 수 있다")
    @MainActor
    func supportsSwiftUIHeaderAndFooterWithoutItem() {
        let section = Section(id: "section", cells: [])
            .withHeader {
                Text("헤더")
            }
            .withFooter {
                Text("푸터")
            }

        #expect(section.header?.kind == UICollectionView.elementKindSectionHeader)
        #expect(section.footer?.kind == UICollectionView.elementKindSectionFooter)
    }
}

private func makeCell(
    id: some Hashable,
    title: String
) -> Cell {
    Cell(
        id: id,
        component: MockComponent(item: .init(title: title))
    )
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
