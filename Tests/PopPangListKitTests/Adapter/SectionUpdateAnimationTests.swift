import DifferenceKit
import Testing
import UIKit
@testable import PopPangListKit

@Suite("Section Update Animation Tests")
struct SectionUpdateAnimationTests {

    @Test("modifier는 Section update animation 정책만 변경한다")
    @MainActor
    func modifierChangesOnlyUpdatePolicy() {
        let source = makeSection(
            id: "best",
            revision: 0
        )
        let disabled = source.disablesUpdateAnimation()
        let enabled = disabled.disablesUpdateAnimation(false)

        #expect(source.isUpdateAnimationDisabled == false)
        #expect(disabled.isUpdateAnimationDisabled)
        #expect(enabled.isUpdateAnimationDisabled == false)
        #expect(source == disabled)
        #expect(source.hashValue == disabled.hashValue)
    }

    @Test("비활성화 Section과 일반 Section의 update를 두 단계로 분리한다")
    @MainActor
    func splitsDisabledAndAnimatedSectionUpdates() throws {
        let source = makeSections(revision: 0)
        let target = makeSections(
            revision: 1,
            disablesBestAnimation: true
        )
        let plan = try #require(
            makeSectionUpdateAnimationPlan(
                source: source,
                target: target
            )
        )

        let nonanimatedChangeset = StagedChangeset(
            source: source,
            target: plan.nonanimatedSections
        )
        let animatedChangeset = StagedChangeset(
            source: plan.nonanimatedSections,
            target: plan.animatedSections
        )

        #expect(
            updatedIndexPaths(in: nonanimatedChangeset) == [
                IndexPath(item: 0, section: 0),
            ]
        )
        #expect(
            updatedIndexPaths(in: animatedChangeset) == [
                IndexPath(item: 0, section: 1),
                IndexPath(item: 0, section: 2),
            ]
        )
    }

    @Test("비활성화 Section의 Header와 Footer update를 첫 단계에 포함한다")
    @MainActor
    func includesSupplementaryUpdatesInNonanimatedPhase() throws {
        let source = [
            makeSectionWithSupplementaries(
                header: "이전 Header",
                footer: "이전 Footer"
            ),
        ]
        let target = [
            makeSectionWithSupplementaries(
                header: "새 Header",
                footer: "새 Footer"
            )
            .disablesUpdateAnimation(),
        ]
        let plan = try #require(
            makeSectionUpdateAnimationPlan(
                source: source,
                target: target
            )
        )

        let nonanimatedChangeset = StagedChangeset(
            source: source,
            target: plan.nonanimatedSections
        )
        let animatedChangeset = StagedChangeset(
            source: plan.nonanimatedSections,
            target: plan.animatedSections
        )

        #expect(nonanimatedChangeset.flatMap(\.sectionUpdated) == [0])
        #expect(animatedChangeset.isEmpty)
    }

    @Test("새로 삽입되는 비활성화 Section은 전체 animated 전략을 따른다")
    @MainActor
    func insertedSectionDoesNotCreateNonanimatedPhase() {
        let source = [
            makeSection(id: "grid", revision: 0),
        ]
        let target = [
            makeSection(id: "best", revision: 1)
                .disablesUpdateAnimation(),
            makeSection(id: "grid", revision: 0),
        ]

        #expect(
            makeSectionUpdateAnimationPlan(
                source: source,
                target: target
            ) == nil
        )
    }

    @Test("Section 이동은 animated 단계에 남긴다")
    @MainActor
    func sectionMoveRemainsInAnimatedPhase() throws {
        let source = [
            makeSection(id: "best", revision: 0),
            makeSection(id: "grid", revision: 0),
        ]
        let target = [
            makeSection(id: "grid", revision: 0),
            makeSection(id: "best", revision: 1)
                .disablesUpdateAnimation(),
        ]
        let plan = try #require(
            makeSectionUpdateAnimationPlan(
                source: source,
                target: target
            )
        )

        let nonanimatedChangeset = StagedChangeset(
            source: source,
            target: plan.nonanimatedSections
        )
        let animatedChangeset = StagedChangeset(
            source: plan.nonanimatedSections,
            target: plan.animatedSections
        )

        #expect(nonanimatedChangeset.flatMap(\.sectionMoved).isEmpty)
        #expect(animatedChangeset.flatMap(\.sectionMoved).isEmpty == false)
    }

    @Test("animated 전체 전략은 Section별 animation 상태로 batch를 분리한다")
    @MainActor
    func animatedStrategyUsesSeparateAnimationStates() async {
        let context = makeVisibleAdapter()
        defer {
            context.window.isHidden = true
        }

        await apply(
            List(sections: makeSections(revision: 0)),
            to: context.adapter
        )
        context.collectionView.batchAnimationStates.removeAll()

        await apply(
            List(
                sections: makeSections(
                    revision: 1,
                    disablesBestAnimation: true
                )
            ),
            to: context.adapter
        )

        #expect(
            context.collectionView.batchAnimationStates == [
                false,
                true,
            ]
        )
    }

    @Test("전체 nonanimated 전략은 Section 정책보다 우선한다")
    @MainActor
    func globalNonanimatedStrategyTakesPrecedence() async {
        let context = makeVisibleAdapter()
        defer {
            context.window.isHidden = true
        }

        await apply(
            List(sections: makeSections(revision: 0)),
            to: context.adapter
        )
        context.collectionView.batchAnimationStates.removeAll()

        await apply(
            List(
                sections: makeSections(
                    revision: 1,
                    disablesBestAnimation: true
                )
            ),
            to: context.adapter,
            updateStrategy: .nonanimatedBatchUpdates
        )

        #expect(context.collectionView.batchAnimationStates == [false])
    }

    @Test("전체 reloadData 전략은 Section 정책보다 우선한다")
    @MainActor
    func globalReloadDataStrategyTakesPrecedence() async {
        let context = makeVisibleAdapter()
        defer {
            context.window.isHidden = true
        }

        await apply(
            List(sections: makeSections(revision: 0)),
            to: context.adapter
        )
        context.collectionView.batchAnimationStates.removeAll()
        context.collectionView.reloadDataCallCount = 0

        await apply(
            List(
                sections: makeSections(
                    revision: 1,
                    disablesBestAnimation: true
                )
            ),
            to: context.adapter,
            updateStrategy: .reloadData
        )

        #expect(context.collectionView.batchAnimationStates.isEmpty)
        #expect(context.collectionView.reloadDataCallCount == 1)
    }

    @Test("Section별 nonanimated 단계는 전체 reload interrupt를 사용하지 않는다")
    @MainActor
    func scopedPhaseDoesNotUseReloadDataInterrupt() async {
        let context = makeVisibleAdapter(
            batchUpdateInterruptCount: 0
        )
        defer {
            context.window.isHidden = true
        }

        await apply(
            List(sections: makeSections(revision: 0)),
            to: context.adapter
        )
        context.collectionView.batchAnimationStates.removeAll()
        context.collectionView.reloadDataCallCount = 0

        let target = [
            makeSection(id: "best", revision: 1)
                .disablesUpdateAnimation(),
            makeSection(id: "coming", revision: 0),
            makeSection(id: "grid", revision: 0),
        ]
        await apply(
            List(sections: target),
            to: context.adapter
        )

        #expect(context.collectionView.batchAnimationStates == [false])
        #expect(context.collectionView.reloadDataCallCount == 0)
    }

    @Test("빠른 연속 snapshot은 두 단계 완료 후 최신 update를 적용한다")
    @MainActor
    func queuedSnapshotsCompleteInOrder() async {
        let context = makeVisibleAdapter()
        defer {
            context.window.isHidden = true
        }

        await apply(
            List(sections: makeSections(revision: 0)),
            to: context.adapter
        )

        var completedRevisions = [Int]()
        await withCheckedContinuation { continuation in
            context.adapter.apply(
                List(
                    sections: makeSections(
                        revision: 1,
                        disablesBestAnimation: true
                    )
                )
            ) {
                completedRevisions.append(1)
            }

            context.adapter.apply(
                List(
                    sections: makeSections(
                        revision: 2,
                        disablesBestAnimation: true
                    )
                )
            ) {
                completedRevisions.append(2)
                continuation.resume()
            }
        }

        let bestComponent = context.adapter.snapshot()?
            .sections[0]
            .cells[0]
            .component
            .as(UpdateAnimationTestComponent.self)

        #expect(completedRevisions == [1, 2])
        #expect(bestComponent?.revision == 2)
    }
}

private extension SectionUpdateAnimationTests {

    struct AdapterContext {
        let window: UIWindow
        let collectionView: RecordingCollectionView
        let adapter: CollectionViewAdapter
    }

    @MainActor
    func makeVisibleAdapter(
        batchUpdateInterruptCount: Int = 100
    ) -> AdapterContext {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 60)

        let collectionView = RecordingCollectionView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 640),
            collectionViewLayout: layout
        )
        let adapter = CollectionViewAdapter(
            configuration: .init(
                batchUpdateInterruptCount: batchUpdateInterruptCount,
                enablesReconfigureItems: true
            ),
            collectionView: collectionView,
            layoutAdapter: CollectionViewLayoutAdapter()
        )

        let viewController = UIViewController()
        viewController.view.frame = collectionView.frame
        viewController.view.addSubview(collectionView)

        let window = UIWindow(frame: collectionView.frame)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        viewController.view.layoutIfNeeded()

        return AdapterContext(
            window: window,
            collectionView: collectionView,
            adapter: adapter
        )
    }

    @MainActor
    func apply(
        _ list: List,
        to adapter: CollectionViewAdapter,
        updateStrategy: CollectionViewAdapterUpdateStrategy = .animatedBatchUpdates
    ) async {
        await withCheckedContinuation { continuation in
            adapter.apply(
                list,
                updateStrategy: updateStrategy
            ) {
                continuation.resume()
            }
        }
    }

    @MainActor
    func makeSections(
        revision: Int,
        disablesBestAnimation: Bool = false
    ) -> [PopPangListKit.Section] {
        let best = makeSection(id: "best", revision: revision)
        return [
            disablesBestAnimation
                ? best.disablesUpdateAnimation()
                : best,
            makeSection(id: "coming", revision: revision),
            makeSection(id: "grid", revision: revision),
        ]
    }

    @MainActor
    func makeSection(
        id: String,
        revision: Int
    ) -> PopPangListKit.Section {
        Section(
            id: id,
            cells: [
                Cell(
                    id: "cell",
                    component: UpdateAnimationTestComponent(
                        revision: revision
                    )
                ),
            ]
        )
    }

    @MainActor
    func makeSectionWithSupplementaries(
        header: String,
        footer: String
    ) -> PopPangListKit.Section {
        makeSection(id: "best", revision: 0)
            .withHeader(
                UpdateAnimationTestComponent(
                    revision: 0,
                    text: header
                )
            )
            .withFooter(
                UpdateAnimationTestComponent(
                    revision: 0,
                    text: footer
                )
            )
    }

    func updatedIndexPaths(
        in changeset: StagedChangeset<[PopPangListKit.Section]>
    ) -> [IndexPath] {
        changeset
            .flatMap(\.elementUpdated)
            .map {
                IndexPath(item: $0.element, section: $0.section)
            }
    }
}

private final class RecordingCollectionView: UICollectionView {
    var batchAnimationStates = [Bool]()
    var reloadDataCallCount = 0

    override func performBatchUpdates(
        _ updates: (() -> Void)?,
        completion: ((Bool) -> Void)? = nil
    ) {
        batchAnimationStates.append(UIView.areAnimationsEnabled)
        super.performBatchUpdates(updates, completion: completion)
    }

    override func reloadData() {
        reloadDataCallCount += 1
        super.reloadData()
    }
}

private struct UpdateAnimationTestComponent: Component {
    let revision: Int
    var text: String?
    let layoutMode: ContentLayoutMode = .flexibleHeight(
        estimatedHeight: 60
    )

    var item: String {
        text ?? "revision-\(revision)"
    }

    init(
        revision: Int,
        text: String? = nil
    ) {
        self.revision = revision
        self.text = text
    }

    @MainActor
    func renderContent(coordinator: Void) -> UILabel {
        UILabel()
    }

    @MainActor
    func render(in content: UILabel, coordinator: Void) {
        content.text = item
    }
}
