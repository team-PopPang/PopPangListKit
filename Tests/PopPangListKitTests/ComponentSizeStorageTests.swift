//
//  ComponentSizeStorageTests.swift
//  PopPangListKitTests
//
//  Created by 김동현 on 7/7/26.
//

import UIKit
import Testing
@testable import PopPangListKit

@Suite("ComponentSizeStorage Tests")
struct ComponentSizeStorageTests {

    @Test("cell size를 저장하고 조회한다")
    @MainActor
    func cellSize() {
        let storage = ComponentSizeStorageImpl()
        let item = AnyItem(component: MockComponent(item: .init(title: "cell")))
        let context: ComponentSizeStorage.SizeContext = (
            size: CGSize(width: 100, height: 50),
            item: item
        )

        storage.setCellSize(context, for: "cell-1")

        let result = storage.cellSize(for: "cell-1")

        #expect(result?.size == CGSize(width: 100, height: 50))
        #expect(result?.item == item)
    }

    @Test("header size를 저장하고 조회한다")
    @MainActor
    func headerSize() {
        let storage = ComponentSizeStorageImpl()
        let item = AnyItem(component: MockComponent(item: .init(title: "header")))
        let context: ComponentSizeStorage.SizeContext = (
            size: CGSize(width: 320, height: 44),
            item: item
        )

        storage.setHeaderSize(context, for: "header-1")

        let result = storage.headerSize(for: "header-1")

        #expect(result?.size == CGSize(width: 320, height: 44))
        #expect(result?.item == item)
    }

    @Test("footer size를 저장하고 조회한다")
    @MainActor
    func footerSize() {
        let storage = ComponentSizeStorageImpl()
        let item = AnyItem(component: MockComponent(item: .init(title: "footer")))
        let context: ComponentSizeStorage.SizeContext = (
            size: CGSize(width: 320, height: 30),
            item: item
        )

        storage.setFooterSize(context, for: "footer-1")

        let result = storage.footerSize(for: "footer-1")

        #expect(result?.size == CGSize(width: 320, height: 30))
        #expect(result?.item == item)
    }

    @Test("저장되지 않은 hash는 nil을 반환한다")
    @MainActor
    func missingHash() {
        let storage = ComponentSizeStorageImpl()

        #expect(storage.cellSize(for: "missing") == nil)
        #expect(storage.headerSize(for: "missing") == nil)
        #expect(storage.footerSize(for: "missing") == nil)
    }

    @Test("cell, header, footer 저장소는 서로 독립적이다")
    @MainActor
    func storesAreIndependent() {
        let storage = ComponentSizeStorageImpl()
        let item = AnyItem(component: MockComponent(item: .init(title: "same-hash")))

        storage.setCellSize((CGSize(width: 100, height: 10), item), for: "same")
        storage.setHeaderSize((CGSize(width: 100, height: 20), item), for: "same")
        storage.setFooterSize((CGSize(width: 100, height: 30), item), for: "same")

        #expect(storage.cellSize(for: "same")?.size.height == 10)
        #expect(storage.headerSize(for: "same")?.size.height == 20)
        #expect(storage.footerSize(for: "same")?.size.height == 30)
    }

    @Test("같은 hash에 다시 저장하면 기존 size를 덮어쓴다")
    @MainActor
    func overwriteSize() {
        let storage = ComponentSizeStorageImpl()
        let item = AnyItem(component: MockComponent(item: .init(title: "overwrite")))

        storage.setCellSize((CGSize(width: 100, height: 50), item), for: "cell")
        storage.setCellSize((CGSize(width: 200, height: 80), item), for: "cell")

        let result = storage.cellSize(for: "cell")

        #expect(result?.size == CGSize(width: 200, height: 80))
        #expect(result?.item == item)
    }

    @Test("같은 raw Cell ID의 size를 Section별로 독립 저장한다")
    @MainActor
    func sameRawCellIDIsScopedBySection() {
        let storage = ComponentSizeStorageImpl()
        let bestCell = Section(
            id: "best",
            cells: [
                Cell(
                    id: "same-popup-id",
                    component: MockComponent(item: .init(title: "popup"))
                ),
            ]
        ).cells[0]
        let gridCell = Section(
            id: "grid",
            cells: [
                Cell(
                    id: "same-popup-id",
                    component: MockComponent(item: .init(title: "popup"))
                ),
            ]
        ).cells[0]

        storage.setCellSize(
            (CGSize(width: 300, height: 100), bestCell.component.item),
            for: bestCell.internalIdentity
        )
        storage.setCellSize(
            (CGSize(width: 150, height: 220), gridCell.component.item),
            for: gridCell.internalIdentity
        )

        #expect(bestCell.id == gridCell.id)
        #expect(bestCell.internalIdentity != gridCell.internalIdentity)
        #expect(
            storage.cellSize(for: bestCell.internalIdentity)?.size
                == CGSize(width: 300, height: 100)
        )
        #expect(
            storage.cellSize(for: gridCell.internalIdentity)?.size
                == CGSize(width: 150, height: 220)
        )
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
