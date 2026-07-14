import Combine
import SwiftUI
import Testing
@testable import PopPangListKit

@Suite("PopPangList Tests")
struct PopPangListTests {
    @Test("UIKit List의 scroll lifecycle modifier를 모두 노출한다")
    @MainActor
    func exposesAllScrollLifecycleModifiers() {
        let list = PopPangList {
            Section(id: "section") {}
        }
        .onRefresh { _ in }
        .onReachEnd { _ in }
        .didScroll { _ in }
        .willBeginDragging { _ in }
        .willEndDragging { _ in }
        .didEndDragging { _ in }
        .didScrollToTop { _ in }
        .willBeginDecelerating { _ in }
        .didEndDecelerating { _ in }
        .shouldScrollToTop { _ in true }

        #expect(String(describing: type(of: list)) == "PopPangList")
    }

    @Test("prefetch plugin을 PopPangList에 전달할 수 있다")
    @MainActor
    func acceptsPrefetchingPlugins() {
        let list = PopPangList(
            prefetchingPlugins: [MockPrefetchingPlugin()]
        ) {
            Section(id: "section") {}
        }

        #expect(String(describing: type(of: list)) == "PopPangList")
    }

    @Test("didScroll 뒤에 scrollOverlay를 연결할 수 있다")
    @MainActor
    func supportsScrollOverlayAfterScrollEventModifier() {
        let list = PopPangList {
            Section(id: "section") {}
        }
        .didScroll { _ in }
        .scrollOverlay(
            alignment: .bottomTrailing,
            visibleWhen: .relativeToViewport(1.5)
        ) { isVisible in
            Text("\(isVisible)")
        }

        #expect(String(describing: type(of: list)).isEmpty == false)
    }
}

private struct MockPrefetchingPlugin: CollectionViewPrefetchingPlugin {
    func prefetch(
        with component: ComponentResourcePrefetchable
    ) -> AnyCancellable? {
        nil
    }
}
