import DifferenceKit
import UIKit

struct CollectionViewItemUpdatePlan: Equatable {
    let reconfiguredIndexPaths: [IndexPath]
    let reloadedIndexPaths: [IndexPath]
}

func makeCollectionViewItemUpdatePlan(
    updatedIndexPaths: [IndexPath],
    usesReconfigureItems: Bool,
    isReconfigurationCompatible: (IndexPath) -> Bool
) -> CollectionViewItemUpdatePlan {
    var reconfiguredIndexPaths = [IndexPath]()
    var reloadedIndexPaths = [IndexPath]()

    for indexPath in updatedIndexPaths {
        let isCompatible = isReconfigurationCompatible(indexPath)

        if usesReconfigureItems,
           isCompatible {
            reconfiguredIndexPaths.append(indexPath)
        } else {
            reloadedIndexPaths.append(indexPath)
        }
    }

    return CollectionViewItemUpdatePlan(
        reconfiguredIndexPaths: reconfiguredIndexPaths,
        reloadedIndexPaths: reloadedIndexPaths
    )
}

extension UICollectionView {
    func reload<C>(
        using stagedChangeset: StagedChangeset<C>,
        interrupt: ((Changeset<C>) -> Bool)? = nil,
        setData: (C) -> Void,
        enablesReconfigureItems: Bool,
        isReconfigurationCompatible: ((IndexPath, C) -> Bool)? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        if stagedChangeset.isEmpty {
            completion?(true)
            return
        }

        if case .none = window, let data = stagedChangeset.last?.data {
            for changeset in stagedChangeset {
                for updatedPath in changeset.elementUpdated {
                    _ = isReconfigurationCompatible?(
                        IndexPath(
                            item: updatedPath.element,
                            section: updatedPath.section
                        ),
                        changeset.data
                    )
                }
            }

            setData(data)
            reloadData()
            layoutIfNeeded()
            completion?(true)
            return
        }

        for (index, changeset) in stagedChangeset.enumerated() {
            if let interrupt, interrupt(changeset), let data = stagedChangeset.last?.data {
                for updatedPath in changeset.elementUpdated {
                    _ = isReconfigurationCompatible?(
                        IndexPath(
                            item: updatedPath.element,
                            section: updatedPath.section
                        ),
                        changeset.data
                    )
                }

                setData(data)
                reloadData()
                layoutIfNeeded()
                completion?(true)
                return
            }

            let isLastUpdate = index == (stagedChangeset.endIndex - 1)
            let updatedIndexPaths = changeset.elementUpdated.map {
                IndexPath(item: $0.element, section: $0.section)
            }
            let usesReconfigureItems: Bool

            if #available(iOS 15.0, *) {
                usesReconfigureItems = enablesReconfigureItems
            } else {
                usesReconfigureItems = false
            }

            let itemUpdatePlan = makeCollectionViewItemUpdatePlan(
                updatedIndexPaths: updatedIndexPaths,
                usesReconfigureItems: usesReconfigureItems,
                isReconfigurationCompatible: {
                    isReconfigurationCompatible?($0, changeset.data) ?? true
                }
            )

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

                if #available(iOS 15.0, *),
                   itemUpdatePlan.reconfiguredIndexPaths.isEmpty == false {
                    reconfigureItems(
                        at: itemUpdatePlan.reconfiguredIndexPaths
                    )
                }

                if itemUpdatePlan.reloadedIndexPaths.isEmpty == false {
                    reloadItems(
                        at: itemUpdatePlan.reloadedIndexPaths
                    )
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
