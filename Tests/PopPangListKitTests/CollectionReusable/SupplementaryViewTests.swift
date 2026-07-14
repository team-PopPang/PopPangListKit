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

    @Test("background를 지정하지 않으면 기존 transparent supplementary 상태를 유지한다")
    func hasNoBackgroundByDefault() {
        let view = SupplementaryView(
            kind: "header",
            component: MockComponent(item: .init(title: "A")),
            alignment: .top
        )

        #expect(view.backgroundColor == nil)
    }

    @Test("UIKit Component Header에 full-bleed background를 선언할 수 있다")
    @MainActor
    func componentHeaderBackground() {
        let section = Section(id: "component-header", cells: [])
            .withHeader(MockComponent(item: .init(title: "Header")))
            .headerBackground(.systemBackground)

        #expect(section.header?.backgroundColor?.isEqual(UIColor.systemBackground) == true)
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

    @Test("SwiftUI Header에 full-bleed background를 선언할 수 있다")
    @MainActor
    func swiftUIHeaderBackground() {
        let section = Section(id: "swiftui-header", cells: [])
            .withHeader {
                Text("추천 팝업")
            }
            .headerBackground(.systemBackground)

        #expect(section.header?.backgroundColor?.isEqual(UIColor.systemBackground) == true)
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

    @Test("item 없는 SwiftUI header는 새 snapshot에서 갱신된다")
    @MainActor
    func swiftUIHeaderRefreshesCapturedState() {
        let first = SupplementaryView.header {
            Text("첫 번째")
        }
        let updated = SupplementaryView.header {
            Text("두 번째")
        }

        #expect(first.kind == UICollectionView.elementKindSectionHeader)
        #expect(first.alignment == .top)
        #expect(first != updated)
    }

    @Test("item 없는 SwiftUI footer는 footer supplementary model로 생성된다")
    @MainActor
    func swiftUIFooter() {
        let footer = SupplementaryView.footer {
            Text("더 보기")
        }
        let updated = SupplementaryView.footer {
            Text("모두 보기")
        }

        #expect(footer.kind == UICollectionView.elementKindSectionFooter)
        #expect(footer.alignment == .bottom)
        #expect(footer != updated)
    }

    @Test("Footer도 같은 full-bleed background API를 사용한다")
    @MainActor
    func swiftUIFooterBackground() {
        let section = Section(id: "footer", cells: [])
            .withFooter {
                Text("더 보기")
            }
            .footerBackground(.secondarySystemBackground)

        #expect(
            section.footer?.backgroundColor?.isEqual(UIColor.secondarySystemBackground) == true
        )
    }

    @Test("item 없는 SwiftUI supplementary view는 전달한 kind와 alignment를 사용한다")
    @MainActor
    func swiftUISupplementaryView() {
        let view = SupplementaryView.swiftUI(
            kind: "badge",
            alignment: .bottom
        ) {
            Text("NEW")
        }
        let updated = SupplementaryView.swiftUI(
            kind: "badge",
            alignment: .bottom
        ) {
            Text("HOT")
        }

        #expect(view.kind == "badge")
        #expect(view.alignment == .bottom)
        #expect(view != updated)
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
