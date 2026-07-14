import SwiftUI
import Testing
import UIKit
@testable import PopPangListKit

@Suite("ScrollOverlay Tests")
struct ScrollOverlayTests {
    @Test("relativeToViewport는 adjustedContentInset을 제외한 세로 offset으로 계산한다")
    @MainActor
    func calculatesRelativeToViewportVisibility() {
        let state = ScrollOverlayVisibilityState()
        state.update(visibleWhen: .relativeToViewport(1.5))

        state.update(
            contentOffsetY: 320,
            adjustedContentInsetTop: 20,
            viewportHeight: 200
        )
        #expect(!state.isVisible)

        state.update(
            contentOffsetY: 321,
            adjustedContentInsetTop: 20,
            viewportHeight: 200
        )
        #expect(state.isVisible)
    }

    @Test("points 기준은 viewport 크기 변경과 무관하고 음수 기준은 0으로 보정한다")
    @MainActor
    func calculatesPointVisibilitySafely() {
        let state = ScrollOverlayVisibilityState()
        state.update(visibleWhen: .points(120))

        state.update(
            contentOffsetY: 140,
            adjustedContentInsetTop: 20,
            viewportHeight: 10
        )
        #expect(!state.isVisible)

        state.update(
            contentOffsetY: 141,
            adjustedContentInsetTop: 20,
            viewportHeight: 1_000
        )
        #expect(state.isVisible)

        state.update(visibleWhen: .points(-1))
        state.update(
            contentOffsetY: 0,
            adjustedContentInsetTop: 0,
            viewportHeight: 200
        )
        #expect(!state.isVisible)
    }

    @Test("didScroll과 scroll overlay observer는 함께 호출된다")
    @MainActor
    func keepsDidScrollAndOverlayObservationIndependent() {
        let (collectionView, adapter) = makeAdapter()
        let state = ScrollOverlayVisibilityState()
        adapter.configureScrollOverlay(
            .init(state: state, visibleWhen: .points(100))
        )

        var didScrollCount = 0
        adapter.apply(
            List {
                Section(id: "section") {}
            }
            .didScroll { _ in
                didScrollCount += 1
            }
        )

        collectionView.contentSize = .init(width: 100, height: 1_000)
        collectionView.contentOffset = .init(x: 0, y: 101)
        didScrollCount = 0
        adapter.scrollViewDidScroll(collectionView)

        #expect(didScrollCount == 1)
        #expect(state.isVisible)
    }

    @Test("overlay 상태 변화는 List apply를 다시 예약하지 않는다")
    @MainActor
    func overlayVisibilityDoesNotApplyListSnapshot() async {
        let viewController = makeViewController()
        let coordinator = PopPangListRepresentable.Coordinator()
        let state = ScrollOverlayVisibilityState()

        coordinator.schedule(
            list: List {
                Section(id: "section") {}
            },
            viewController: viewController,
            proxy: nil,
            scrollOverlayConfiguration: .init(
                state: state,
                visibleWhen: .points(100)
            )
        )
        for _ in 0..<10 where viewController.appliedListCount == 0 {
            await Task.yield()
        }

        #expect(viewController.appliedListCount == 1)

        state.update(
            contentOffsetY: 101,
            adjustedContentInsetTop: 0,
            viewportHeight: 100
        )
        await Task.yield()

        #expect(state.isVisible)
        #expect(viewController.appliedListCount == 1)
    }
}

private extension ScrollOverlayTests {
    @MainActor
    func makeAdapter() -> (UICollectionView, CollectionViewAdapter) {
        let layoutAdapter = CollectionViewLayoutAdapter()
        let collectionView = UICollectionView(layoutAdapter: layoutAdapter)
        collectionView.frame = .init(x: 0, y: 0, width: 100, height: 100)

        let adapter = CollectionViewAdapter(
            configuration: .init(),
            collectionView: collectionView,
            layoutAdapter: layoutAdapter
        )
        return (collectionView, adapter)
    }

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
}
