#if canImport(UIKit)
import UIKit

extension UICollectionView {
    public convenience init(layoutAdapter: CollectionViewLayoutAdaptable) {
        self.init(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(
                sectionProvider: layoutAdapter.sectionLayout
            )
        )
    }
}
#endif
