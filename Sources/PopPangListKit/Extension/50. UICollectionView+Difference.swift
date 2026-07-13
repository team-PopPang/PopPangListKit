import DifferenceKit
import UIKit

extension UICollectionView {
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void,
        enablesReconfigureItems: Bool,
        completion: ((Bool) -> Void)? = nil
    ) {
        if stagedChangeset.isEmpty {
            completion?(true)
            return
        }

        if case .none = window, let data = stagedChangeset.last?.data {
            setData(data)
            reloadData()
            layoutIfNeeded()
            completion?(true)
            return
        }

        for (index, changeset) in stagedChangeset.enumerated() {
            if let interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                setData(data)
                reloadData()
                layoutIfNeeded()
                completion?(true)
                return
            }

            let isLastUpdate = index == (stagedChangeset.endIndex - 1)

            performBatchUpdates({
                setData(changeset.data)

                if changeset.sectionDeleted.isEmpty == false {
                    deleteSections(IndexSet(changeset.sectionDeleted))
                }

                if changeset.sectionInserted.isEmpty == false {
                    insertSections(IndexSet(changeset.sectionInserted))
                }

                if changeset.sectionUpdated.isEmpty == false {
                    reloadSections(IndexSet(changeset.sectionUpdated))
                }

                for (source, target) in changeset.sectionMoved {
                    moveSection(source, toSection: target)
                }

                if changeset.elementDeleted.isEmpty == false {
                    deleteItems(at: changeset.elementDeleted.map { IndexPath(item: $0.element, section: $0.section) })
                }

                if changeset.elementInserted.isEmpty == false {
                    insertItems(at: changeset.elementInserted.map { IndexPath(item: $0.element, section: $0.section) })
                }

                if changeset.elementUpdated.isEmpty == false {
                    let updatedIndexPaths = changeset.elementUpdated.map {
                        IndexPath(item: $0.element, section: $0.section)
                    }

                    if #available(iOS 15.0, *), enablesReconfigureItems {
                        reconfigureItems(at: updatedIndexPaths)
                    } else {
                        reloadItems(at: updatedIndexPaths)
                    }
                }

                for (source, target) in changeset.elementMoved {
                    moveItem(
                        at: IndexPath(item: source.element, section: source.section),
                        to: IndexPath(item: target.element, section: target.section)
                    )
                }
            }, completion: isLastUpdate ? completion : nil)
        }
    }
}
