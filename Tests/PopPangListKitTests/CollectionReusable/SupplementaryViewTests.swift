//
//  SupplementaryViewTests.swift
//  PopPangListKitTests
//
//  Created by 김동현 on 7/7/26.
//

import UIKit
import SwiftUI
import Testing
@testable import PopPangListKit

@Suite("SupplementaryView Tests")
struct SupplementaryViewTests {

    @Test("초기화 시 kind, component, alignment를 저장한다")
    func initialize() {
        let view = SupplementaryView(
            kind: "header",
            component: MockComponent(item: .init(title: "A")),
            alignment: .top
        )

        #expect(view.kind == "header")
        #expect(view.alignment == .top)
        #expect(view.component == AnyComponent(component: MockComponent(item: .init(title: "A"))))
    }

    @Test("kind, component, alignment가 모두 같으면 true")
    func equal() {
        let lhs = SupplementaryView(
            kind: "header",
            component: MockComponent(item: .init(title: "A")),
            alignment: .top
        )

        let rhs = SupplementaryView(
            kind: "header",
            component: MockComponent(item: .init(title: "A")),
            alignment: .top
        )

        #expect(lhs == rhs)
    }

    @Test("kind가 다르면 false")
    func differentKind() {
        let lhs = SupplementaryView(
            kind: "header",
            component: MockComponent(item: .init(title: "A")),
            alignment: .top
        )

        let rhs = SupplementaryView(
            kind: "footer",
            component: MockComponent(item: .init(title: "A")),
            alignment: .top
        )

        #expect(lhs != rhs)
    }

    @Test("component item이 다르면 false")
    func differentComponent() {
        let lhs = SupplementaryView(
            kind: "header",
            component: MockComponent(item: .init(title: "A")),
            alignment: .top
        )

        let rhs = SupplementaryView(
            kind: "header",
            component: MockComponent(item: .init(title: "B")),
            alignment: .top
        )

        #expect(lhs != rhs)
    }

    @Test("alignment가 다르면 false")
    func differentAlignment() {
        let lhs = SupplementaryView(
            kind: "header",
            component: MockComponent(item: .init(title: "A")),
            alignment: .top
        )

        let rhs = SupplementaryView(
            kind: "header",
            component: MockComponent(item: .init(title: "A")),
            alignment: .bottom
        )

        #expect(lhs != rhs)
    }

    @Test("SwiftUI header는 기존 supplementary model로 생성된다")
    @MainActor
    func swiftUIHeader() {
        let header = SupplementaryView.header(item: "추천 팝업") { title in
            Text(title)
        }

        #expect(header.kind == UICollectionView.elementKindSectionHeader)
        #expect(header.alignment == .top)
    }

    @Test("SwiftUI header의 item이 달라지면 변경으로 판단한다")
    @MainActor
    func swiftUIHeaderDetectsItemChange() {
        let first = SupplementaryView.header(item: "첫 번째") { title in
            Text(title)
        }
        let updated = SupplementaryView.header(item: "두 번째") { title in
            Text(title)
        }

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
