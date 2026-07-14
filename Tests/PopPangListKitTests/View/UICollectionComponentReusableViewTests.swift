import Testing
import UIKit
@testable import PopPangListKit

@Suite("UICollectionComponentReusableView Tests")
struct UICollectionComponentReusableViewTests {

    @Test("section inset 안의 supplementary 콘텐츠는 유지하고 배경만 collection 전체 폭으로 확장한다")
    @MainActor
    func fullBleedBackgroundKeepsContentFrame() {
        let collectionView = makeCollectionView(width: 320)
        let reusableView = UICollectionComponentReusableView(
            frame: .init(x: 15, y: 80, width: 290, height: 44)
        )

        reusableView.render(component: AnyComponent(component: MockComponent()))
        reusableView.applySupplementaryBackgroundColor(.systemBackground)
        collectionView.addSubview(reusableView)
        reusableView.layoutIfNeeded()

        guard let content = reusableView.renderedContent,
              let background = reusableView.fullBleedBackgroundView
        else {
            Issue.record("Expected rendered content and full-bleed background")
            return
        }

        #expect(content.frame == reusableView.bounds)
        #expect(background.frame.minX == -15)
        #expect(background.frame.width == 320)
        #expect(background.frame.height == reusableView.bounds.height)
        #expect(background.isUserInteractionEnabled == false)
    }

    @Test("pinned 상태로 frame이 바뀌어도 full-bleed background를 다시 계산한다")
    @MainActor
    func fullBleedBackgroundUpdatesWhenHeaderPins() {
        let collectionView = makeCollectionView(width: 320)
        let reusableView = UICollectionComponentReusableView(
            frame: .init(x: 15, y: 120, width: 290, height: 44)
        )
        collectionView.addSubview(reusableView)
        reusableView.applySupplementaryBackgroundColor(.systemBackground)
        reusableView.layoutIfNeeded()

        reusableView.frame.origin.y = 0
        reusableView.setNeedsLayout()
        reusableView.layoutIfNeeded()

        guard let background = reusableView.fullBleedBackgroundView else {
            Issue.record("Expected full-bleed background")
            return
        }

        #expect(background.frame.minX == -15)
        #expect(background.frame.width == collectionView.bounds.width)
        #expect(background.frame.height == reusableView.bounds.height)
    }

    @Test("collection width와 supplementary frame이 변경되면 배경 폭을 갱신한다")
    @MainActor
    func fullBleedBackgroundUpdatesAfterWidthChange() {
        let collectionView = makeCollectionView(width: 320)
        let reusableView = UICollectionComponentReusableView(
            frame: .init(x: 15, y: 0, width: 290, height: 44)
        )
        collectionView.addSubview(reusableView)
        reusableView.applySupplementaryBackgroundColor(.systemBackground)
        reusableView.layoutIfNeeded()

        collectionView.frame.size.width = 480
        reusableView.frame.size.width = 450
        reusableView.setNeedsLayout()
        reusableView.layoutIfNeeded()

        guard let background = reusableView.fullBleedBackgroundView else {
            Issue.record("Expected full-bleed background")
            return
        }

        #expect(background.frame.minX == -15)
        #expect(background.frame.width == 480)
    }

    @Test("background를 지정하지 않거나 제거하면 full-bleed view를 만들지 않는다")
    @MainActor
    func backgroundIsOptional() {
        let reusableView = UICollectionComponentReusableView(frame: .zero)

        #expect(reusableView.fullBleedBackgroundView == nil)

        reusableView.applySupplementaryBackgroundColor(.systemBackground)
        #expect(reusableView.fullBleedBackgroundView != nil)

        reusableView.applySupplementaryBackgroundColor(nil)
        #expect(reusableView.fullBleedBackgroundView == nil)
        #expect(reusableView.backgroundColor?.isEqual(UIColor.clear) == true)
    }

    private func makeCollectionView(width: CGFloat) -> UICollectionView {
        UICollectionView(
            frame: .init(x: 0, y: 0, width: width, height: 480),
            collectionViewLayout: UICollectionViewFlowLayout()
        )
    }
}

private struct MockComponent: Component {
    let item = "supplementary"
    let layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44)

    @MainActor
    func renderContent(coordinator: Void) -> UIView {
        UIView()
    }

    @MainActor
    func render(in content: UIView, coordinator: Void) {}
}
