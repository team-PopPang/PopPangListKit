import SwiftUI
import Testing
import UIKit
@testable import PopPangListKit

@Suite("ListProxy Tests")
struct ListProxyTests {
    @Test("기존 PopPangList 초기화와 ListProxy 초기화를 모두 지원한다")
    @MainActor
    func supportsSourceCompatibleInitializer() {
        let proxy = ListProxy()
        let existingList = PopPangList {
            Section(id: "existing") {}
        }
        let proxiedList = PopPangList(proxy: proxy) {
            Section(id: "proxied") {}
        }

        #expect(String(describing: type(of: existingList)) == "PopPangList")
        #expect(String(describing: type(of: proxiedList)) == "PopPangList")
    }

    @Test("PopPangListProxy alias는 deprecated 상태로 호환된다")
    @MainActor
    func supportsDeprecatedProxyAlias() {
        let legacyProxy = PopPangListProxy()
        let proxy: ListProxy = legacyProxy

        #expect(proxy === legacyProxy)
    }

    @Test("scrollToTop은 adjustedContentInset을 반영한다")
    @MainActor
    func scrollToTopUsesAdjustedContentInset() {
        let proxy = ListProxy()
        let viewController = makeViewController()
        viewController.collectionView.contentInsetAdjustmentBehavior = .never
        viewController.collectionView.contentInset.top = 24
        viewController.collectionView.contentOffset = .init(x: 8, y: 300)
        proxy.attach(viewController)

        #expect(proxy.scrollToTop(animated: false))
        #expect(
            viewController.collectionView.contentOffset == .init(
                x: 8,
                y: -viewController.collectionView.adjustedContentInset.top
            )
        )
    }

    @Test("String과 Int section ID를 최신 snapshot에서 찾는다")
    @MainActor
    func scrollToSectionSupportsHashableIDsAndLatestSnapshot() {
        let proxy = ListProxy()
        let viewController = makeViewController()
        proxy.attach(viewController)

        viewController.apply(
            makeList(
                stringSectionHasCell: true,
                sectionOrder: ["string", "int"]
            )
        )
        viewController.collectionView.layoutIfNeeded()

        #expect(proxy.scrollToSection(id: "string", position: .top, animated: false))
        #expect(proxy.scrollToSection(id: 7, position: .top, animated: false))

        viewController.apply(
            makeList(
                stringSectionHasCell: false,
                sectionOrder: ["int", "string"]
            )
        )
        viewController.collectionView.layoutIfNeeded()

        #expect(proxy.scrollToSection(id: 7, position: .top, animated: false))
        #expect(!proxy.scrollToSection(id: "string", position: .top, animated: false))
    }

    @Test("미연결, 존재하지 않는 ID, 빈 section, 연결 해제 후 호출은 false를 반환한다")
    @MainActor
    func safelyRejectsUnavailableScrollCommands() {
        let proxy = ListProxy()

        #expect(!proxy.scrollToTop(animated: false))
        #expect(!proxy.scrollToSection(id: "missing", position: .top, animated: false))

        let viewController = makeViewController()
        viewController.apply(makeList(stringSectionHasCell: false, sectionOrder: ["string"]))
        let coordinator = PopPangListRepresentable.Coordinator()
        coordinator.schedule(
            list: makeList(stringSectionHasCell: false, sectionOrder: ["string"]),
            viewController: viewController,
            proxy: proxy,
            scrollOverlayConfiguration: nil
        )

        #expect(proxy.scrollToTop(animated: false))
        #expect(!proxy.scrollToSection(id: "string", position: .top, animated: false))
        #expect(!proxy.scrollToSection(id: "missing", position: .top, animated: false))

        coordinator.dismantle(viewController)

        #expect(!proxy.scrollToTop(animated: false))
        #expect(!proxy.scrollToSection(id: "string", position: .top, animated: false))
    }
}

private extension ListProxyTests {
    @MainActor
    func makeViewController() -> PopPangListViewController {
        let viewController = PopPangListViewController(
            configuration: .init(),
            prefetchingPlugins: []
        )
        viewController.loadViewIfNeeded()
        viewController.view.frame = .init(x: 0, y: 0, width: 320, height: 640)
        viewController.view.layoutIfNeeded()
        return viewController
    }

    @MainActor
    func makeList(
        stringSectionHasCell: Bool,
        sectionOrder: [String]
    ) -> PopPangListKit.List {
        let stringSection = PopPangListKit.Section(id: "string") {
            if stringSectionHasCell {
                Cell(id: "string-cell") {
                    Text("String")
                }
            }
        }
        .withSectionLayout(VerticalLayout())

        let intSection = PopPangListKit.Section(id: 7) {
            Cell(id: "int-cell") {
                Text("Int")
            }
        }
        .withSectionLayout(VerticalLayout())

        let sections = sectionOrder.compactMap { identifier -> PopPangListKit.Section? in
            switch identifier {
            case "string":
                stringSection
            case "int":
                intSection
            default:
                nil
            }
        }
        return PopPangListKit.List(sections: sections)
    }
}
