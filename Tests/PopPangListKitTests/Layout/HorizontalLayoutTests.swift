import Testing
import UIKit
@testable import PopPangListKit

@Suite("HorizontalLayout Tests")
struct HorizontalLayoutTests {
    @Test("paging 계열은 반복 card group을 사용한다", arguments: [
        UICollectionLayoutSectionOrthogonalScrollingBehavior.continuousGroupLeadingBoundary,
        .paging,
        .groupPaging,
        .groupPagingCentered,
    ])
    @MainActor
    func pagingBehaviorsUseRepeatingItemGroup(
        behavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
    ) {
        let layout = HorizontalLayout(scrollingBehavior: behavior)

        #expect(layout.usesRepeatingItemGroup)
    }

    @Test("가변 card 경로 behavior는 하나의 group을 사용한다", arguments: [
        UICollectionLayoutSectionOrthogonalScrollingBehavior.none,
        .continuous,
    ])
    @MainActor
    func variableCardBehaviorsUseSingleGroup(
        behavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
    ) {
        let layout = HorizontalLayout(scrollingBehavior: behavior)

        #expect(!layout.usesRepeatingItemGroup)
    }
}
