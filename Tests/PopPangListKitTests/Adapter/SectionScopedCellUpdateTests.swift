import DifferenceKit
import SwiftUI
import Testing
import UIKit
@testable import PopPangListKit

@Suite("Section-scoped Cell Update Tests")
struct SectionScopedCellUpdateTests {

    @Test("같은 raw Cell ID를 서로 다른 Section에서 독립적으로 diff한다")
    @MainActor
    func sameRawCellIDInDifferentSections() {
        let source = makeComponentSections(
            bestTitle: "이전 Best",
            gridTitle: "이전 Grid"
        )
        let target = makeComponentSections(
            bestTitle: "새 Best",
            gridTitle: "새 Grid"
        )

        #expect(source[0].cells[0].id == source[1].cells[0].id)
        #expect(
            source[0].cells[0].differenceIdentifier
                != source[1].cells[0].differenceIdentifier
        )

        let changeset = StagedChangeset(source: source, target: target)
        let updatedIndexPaths = changeset
            .flatMap(\.elementUpdated)
            .map {
                IndexPath(item: $0.element, section: $0.section)
            }
        let movedItems = changeset.flatMap(\.elementMoved)

        #expect(
            Set(updatedIndexPaths) == Set([
                IndexPath(item: 0, section: 0),
                IndexPath(item: 0, section: 1),
            ])
        )
        #expect(movedItems.isEmpty)
    }

    @Test("서로 다른 Section의 SwiftUI View 타입은 snapshot 재적용 시 충돌하지 않는다")
    @MainActor
    func differentSwiftUIViewTypesDoNotConflictOnReapply() async {
        let context = makeVisibleAdapter()
        defer {
            context.window.isHidden = true
        }

        await apply(
            makeSwiftUIList(title: "이전"),
            to: context.adapter
        )
        context.collectionView.layoutIfNeeded()

        await apply(
            makeSwiftUIList(title: "새 값"),
            to: context.adapter
        )
        context.collectionView.layoutIfNeeded()

        let snapshot = context.adapter.snapshot()
        let bestCell = snapshot?.sections[0].cells[0]
        let gridCell = snapshot?.sections[1].cells[0]

        #expect(bestCell?.id == gridCell?.id)
        #expect(
            bestCell?.component.reuseIdentifier
                != gridCell?.component.reuseIdentifier
        )
        #expect(context.collectionView.numberOfSections == 2)
    }

    @Test("같은 Section과 reuseIdentifier의 콘텐츠 변경은 정상 갱신된다")
    @MainActor
    func sameReuseIdentifierContentUpdateRendersNewContent() async {
        let source = makeUIKitList(
            component: LabelComponent(title: "이전")
        )
        let target = makeUIKitList(
            component: LabelComponent(title: "새 값")
        )
        let changeset = StagedChangeset(
            source: source.sections,
            target: target.sections
        )
        let updatedIndexPaths = changeset
            .flatMap(\.elementUpdated)
            .map {
                IndexPath(item: $0.element, section: $0.section)
            }
        let sourceCell = source.sections[0].cells[0]
        let targetCell = target.sections[0].cells[0]
        let plan = makeCollectionViewItemUpdatePlan(
            updatedIndexPaths: updatedIndexPaths,
            usesReconfigureItems: true,
            isReconfigurationCompatible: { _ in
                sourceCell.component.reuseIdentifier
                    == targetCell.component.reuseIdentifier
            }
        )

        #expect(
            plan.reconfiguredIndexPaths == [
                IndexPath(item: 0, section: 0),
            ]
        )
        #expect(plan.reloadedIndexPaths.isEmpty)

        let context = makeVisibleAdapter()
        defer {
            context.window.isHidden = true
        }

        await apply(source, to: context.adapter)
        context.collectionView.layoutIfNeeded()

        await apply(target, to: context.adapter)
        context.collectionView.layoutIfNeeded()

        let cell = context.collectionView.cellForItem(
            at: IndexPath(item: 0, section: 0)
        ) as? UICollectionViewComponentCell
        let label = cell?.renderedContent as? UILabel

        #expect(label?.text == "새 값")
    }

    @Test("reuseIdentifier가 바뀌는 update는 reconfigure하지 않고 reload한다")
    @MainActor
    func changedReuseIdentifierUsesReload() async {
        let source = makeUIKitList(
            component: LabelComponent(title: "Label")
        )
        let target = makeUIKitList(
            component: ButtonComponent(title: "Button")
        )
        let changeset = StagedChangeset(
            source: source.sections,
            target: target.sections
        )
        let updatedIndexPaths = changeset
            .flatMap(\.elementUpdated)
            .map {
                IndexPath(item: $0.element, section: $0.section)
            }
        let sourceCell = source.sections[0].cells[0]
        let targetCell = target.sections[0].cells[0]

        let plan = makeCollectionViewItemUpdatePlan(
            updatedIndexPaths: updatedIndexPaths,
            usesReconfigureItems: true,
            isReconfigurationCompatible: { _ in
                sourceCell.component.reuseIdentifier
                    == targetCell.component.reuseIdentifier
            }
        )

        #expect(plan.reconfiguredIndexPaths.isEmpty)
        #expect(
            plan.reloadedIndexPaths == [
                IndexPath(item: 0, section: 0),
            ]
        )

        let context = makeVisibleAdapter()
        defer {
            context.window.isHidden = true
        }

        await apply(source, to: context.adapter)
        context.collectionView.layoutIfNeeded()
        await apply(target, to: context.adapter)
        context.collectionView.layoutIfNeeded()

        let cell = context.collectionView.cellForItem(
            at: IndexPath(item: 0, section: 0)
        ) as? UICollectionViewComponentCell

        #expect(cell?.renderedContent is UIButton)
    }

    @Test("Section 간 Cell 이동은 move 대신 delete와 insert로 처리한다")
    @MainActor
    func crossSectionMoveBecomesDeleteAndInsert() {
        let source = [
            PopPangListKit.Section(
                id: "best",
                cells: [makeCell(component: LabelComponent(title: "Popup"))]
            ),
            PopPangListKit.Section(id: "grid", cells: []),
        ]
        let target = [
            PopPangListKit.Section(id: "best", cells: []),
            PopPangListKit.Section(
                id: "grid",
                cells: [makeCell(component: LabelComponent(title: "Popup"))]
            ),
        ]

        let changeset = StagedChangeset(source: source, target: target)

        #expect(changeset.flatMap(\.elementMoved).isEmpty)
        #expect(changeset.flatMap(\.elementDeleted).count == 1)
        #expect(changeset.flatMap(\.elementInserted).count == 1)
    }
}

private extension SectionScopedCellUpdateTests {

    struct AdapterContext {
        let window: UIWindow
        let collectionView: UICollectionView
        let adapter: CollectionViewAdapter
    }

    @MainActor
    func makeVisibleAdapter() -> AdapterContext {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 300, height: 60)

        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 320, height: 640),
            collectionViewLayout: layout
        )
        let layoutAdapter = CollectionViewLayoutAdapter()
        let adapter = CollectionViewAdapter(
            configuration: .init(enablesReconfigureItems: true),
            collectionView: collectionView,
            layoutAdapter: layoutAdapter
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
        _ list: PopPangListKit.List,
        to adapter: CollectionViewAdapter
    ) async {
        await withCheckedContinuation { continuation in
            adapter.apply(list) {
                continuation.resume()
            }
        }
    }

    @MainActor
    func makeComponentSections(
        bestTitle: String,
        gridTitle: String
    ) -> [PopPangListKit.Section] {
        [
            PopPangListKit.Section(
                id: "best",
                cells: [
                    makeCell(
                        component: LabelComponent(title: bestTitle)
                    ),
                ]
            ),
            PopPangListKit.Section(
                id: "grid",
                cells: [
                    makeCell(
                        component: ButtonComponent(title: gridTitle)
                    ),
                ]
            ),
        ]
    }

    @MainActor
    func makeSwiftUIList(title: String) -> PopPangListKit.List {
        let popup = Popup(id: "same-popup-id", title: title)

        return PopPangListKit.List {
            PopPangListKit.Section(id: "best") {
                For([popup], id: \.id) {
                    BestPopupCell(popup: $0)
                }
            }
            PopPangListKit.Section(id: "grid") {
                For([popup], id: \.id) {
                    GridPopupCell(popup: $0)
                }
            }
        }
    }

    @MainActor
    func makeUIKitList(
        component: some Component
    ) -> PopPangListKit.List {
        PopPangListKit.List {
            PopPangListKit.Section(id: "section") {
                makeCell(component: component)
            }
        }
    }

    func makeCell(
        component: some Component
    ) -> Cell {
        Cell(id: "same-popup-id", component: component)
    }
}

private struct Popup: Equatable {
    let id: String
    let title: String
}

private struct BestPopupCell: View {
    let popup: Popup

    var body: some View {
        Text("Best \(popup.title)")
    }
}

private struct GridPopupCell: View {
    let popup: Popup

    var body: some View {
        Text("Grid \(popup.title)")
    }
}

private struct LabelComponent: Component {
    let title: String
    let layoutMode: ContentLayoutMode = .flexibleHeight(
        estimatedHeight: 60
    )

    var item: String {
        title
    }

    @MainActor
    func renderContent(coordinator: Void) -> UILabel {
        UILabel()
    }

    @MainActor
    func render(in content: UILabel, coordinator: Void) {
        content.text = title
    }
}

private struct ButtonComponent: Component {
    let title: String
    let layoutMode: ContentLayoutMode = .flexibleHeight(
        estimatedHeight: 60
    )

    var item: String {
        title
    }

    @MainActor
    func renderContent(coordinator: Void) -> UIButton {
        UIButton(type: .system)
    }

    @MainActor
    func render(in content: UIButton, coordinator: Void) {
        content.setTitle(title, for: .normal)
    }
}
