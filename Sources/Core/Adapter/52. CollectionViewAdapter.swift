//
//  CollectionViewAdapter.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Combine
import DifferenceKit

import UIKit

/// UICollectionView를 위한 어댑터
///
/// CollectionViewAdapter는 UICollectionView 로직과 ListKit 로직 사이를 연결하는 역할을 하며,
/// 프레임워크의 핵심 구현을 내부에 캡슐화한다.
///
/// 내부적으로 collectionView의 delegate와 dataSource를 사용한다.
/// 콜백이 필요하다면 modifier를 통해 받아야 하며,
/// collectionView의 delegate와 dataSource를 직접 설정하면 안 된다.
final public class CollectionViewAdapter: NSObject {

    /// 어댑터 설정값
    public var configuration: CollectionViewAdapterConfiguration
    
    /// 등록된 셀 reuseIdentifier 집합
    public var registeredCellReuseIdentifiers = Set<String>()
    
    /// 등록된 헤더 reuseIdentifier 집합
    public var registeredHeaderReuseIdentifiers = Set<String>()
    
    /// 등록된 푸터 reuseIdentifier 집합
    public var registeredFooterReuseIdentifiers = Set<String>()
    
    /// 연결된 UICollectionView
    private weak var collectionView: UICollectionView?
    
    /// indexPath별 프리패칭 작업 (취소 가능하도록 저장)
    private(set) var prefetchingIndexPathOperations = [IndexPath: [AnyCancellable]]()
    
    /// 프리패칭 플러그인 목록
    private let prefetchingPlugins: [CollectionViewPrefetchingPlugin]
    
    /// 현재 업데이트 진행 중 여부
    private var isUpdating = false
    
    /// pull-to-refresh로 시작된 업데이트 여부
    private var isHandlingPullToRefresh = false

    /// 업데이트 도중 들어온 다음 업데이트 요청 (큐)
    private var queuedUpdate: (
        list: List,
        updateStrategy: CollectionViewAdapterUpdateStrategy,
        completion: (() -> Void)?
    )?
    
    /// 셀/헤더/푸터 사이즈 캐시 저장소
    private var componentSizeStorage: ComponentSizeStorage = ComponentSizeStorageImpl()
    
    /// 현재 화면에 반영된 데이터 상태
    var list: List?
    
    /// pull-to-refresh 컨트롤
    private lazy var pullToRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = configuration.refreshControl.tintColor
        refreshControl.attributedTitle = NSAttributedString(
            string: configuration.refreshControl.text ?? "",
            attributes: configuration.refreshControl.textColor.map {
                [.foregroundColor: $0]
            } ?? [:]
        )
        refreshControl.addTarget(
            self,
            action: #selector(pullToRefresh),
            for: .valueChanged
        )
        return refreshControl
    }()
    
    @objc
    @MainActor
    private func pullToRefresh() {
        isHandlingPullToRefresh = true
        list?.event(for: PullToRefreshEvent.self)?.handler(.init())
    }
    
    /// CollectionViewAdapter 초기화
    ///
    /// - Parameters:
    ///   - configuration: 어댑터 설정
    ///   - collectionView: 화면에 표시될 UICollectionView
    ///   - layoutAdapter: 데이터와 레이아웃을 연결하는 어댑터
    ///   - prefetchingPlugins: 리소스 프리패칭 플러그인 목록
    public init(
        configuration: CollectionViewAdapterConfiguration,
        collectionView: UICollectionView,
        layoutAdapter: CollectionViewLayoutAdaptable,
        prefetchingPlugins: [CollectionViewPrefetchingPlugin] = []
    ) {
        self.configuration = configuration
        self.prefetchingPlugins = prefetchingPlugins
        super.init()
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        layoutAdapter.dataSource = self
        
        if prefetchingPlugins.isEmpty == false {
            collectionView.prefetchDataSource = self
        }
        
        if configuration.refreshControl.isEnabled {
            collectionView.refreshControl = pullToRefreshControl
            configureRefreshControlAppearance()
        }
    }
    
    /// List 데이터를 기반으로 UI를 업데이트한다
    ///
    /// - Parameters:
    ///   - list: 새로운 데이터 상태
    ///   - updateStrategy: 업데이트 방식 (애니메이션, 비애니메이션, reload 등)
    ///   - completion: 업데이트 완료 후 실행되는 콜백
    ///
    /// - Note:
    /// 내부적으로 diff 계산(DifferenceKit)을 사용하여 변경된 부분만 업데이트한다.
    @MainActor
    public func apply(
        _ list: List,
        updateStrategy: CollectionViewAdapterUpdateStrategy = .animatedBatchUpdates,
        completion: (() -> Void)? = nil
    ) {
        guard let collectionView else { return }
        
        /// 이미 업데이트 중이면 큐에 저장
        guard isUpdating == false else {
            queuedUpdate = (list, updateStrategy, completion)
            return
        }
        isUpdating = true
        
        /// 내부 completion 래핑
        let overridedCompletion: (Bool) -> Void = { [weak self] _ in
            guard let self else {
                return
            }
            
            if isHandlingPullToRefresh {
                isHandlingPullToRefresh = false
                pullToRefreshControl.endRefreshing()
            }
            
            completion?()
            
            /// 대기 중인 업데이트가 있으면 이어서 실행
            if let nextUpdate = queuedUpdate, collectionView.window != nil {
                queuedUpdate = nil
                isUpdating = false
                apply(
                    nextUpdate.list,
                    updateStrategy: nextUpdate.updateStrategy,
                    completion: nextUpdate.completion
                )
            } else {
                isUpdating = false
            }
        }
        
        /// reuseIdentifier 등록
        registerReuseIdentifiers(with: list.sections)
        
        /// 최초 데이터인 경우
        if self.list == nil || self.list?.sections.count == 0 {
            self.list = list
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            overridedCompletion(true)
            return
        }
        
        /// 업데이트 전략에 따라 처리
        switch updateStrategy {
        case .animatedBatchUpdates:
            performDifferentialUpdates(old: self.list, new: list, completion: overridedCompletion)
            
        case .nonanimatedBatchUpdates:
            UIView.performWithoutAnimation {
                performDifferentialUpdates(old: self.list, new: list, completion: overridedCompletion)
            }
            
        case .reloadData:
            self.list = list
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            overridedCompletion(true)
        }
    }
    
    /// 현재 데이터 상태 반환
    public func snapshot() -> List? {
        list
    }
    
    /// 셀 / 헤더 / 푸터 reuseIdentifier 등록
    @MainActor
    private func registerReuseIdentifiers(with sections: [Section]) {
        sections.forEach { section in
            
            /// 셀 / 헤더 / 푸터 reuseIdentifier 등록
            if let headerReuseIdentifier = section.header?.component.reuseIdentifier,
               !registeredHeaderReuseIdentifiers.contains(headerReuseIdentifier) {
                registeredHeaderReuseIdentifiers.insert(headerReuseIdentifier)
                collectionView?.register(
                    UICollectionComponentReusableView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: headerReuseIdentifier
                )
            }
            
            if let footerReuseIdentifier = section.footer?.component.reuseIdentifier,
               !registeredFooterReuseIdentifiers.contains(footerReuseIdentifier) {
                registeredFooterReuseIdentifiers.insert(footerReuseIdentifier)
                collectionView?.register(
                    UICollectionComponentReusableView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: footerReuseIdentifier
                )
            }
            
            let cellReuseIdentifiers = Set(section.cells.map { $0.component.reuseIdentifier })
            cellReuseIdentifiers
                .subtracting(registeredCellReuseIdentifiers)
                .forEach { reuseIdentifier in
                    registeredCellReuseIdentifiers.insert(reuseIdentifier)
                    collectionView?.register(
                        UICollectionViewComponentCell.self,
                        forCellWithReuseIdentifier: reuseIdentifier
                    )
                }
        }
    }
    
    /// indexPath에 해당하는 Cell 반환
    @MainActor
    private func item(at indexPath: IndexPath) -> Cell? {
        sectionItem(at: indexPath.section)?.cells[safe: indexPath.item]
    }
    
    /// DifferenceKit을 사용한 diff 업데이트 수행
    private func performDifferentialUpdates(
        old: List?,
        new: List?,
        completion: @escaping (Bool) -> Void
    ) {
        let changeset = StagedChangeset(
            source: old?.sections ?? [],
            target: new?.sections ?? []
        )

        collectionView?.reload(
            using: changeset,
            interrupt: { [configuration] changeset in
                changeset.changeCount > configuration.batchUpdateInterruptCount
            },
            setData: { [weak self] sections in
                self?.list?.sections = sections
            },
            enablesReconfigureItems: configuration.enablesReconfigureItems,
            completion: completion
        )
    }
}

// MARK: - Next Batch Trigger
extension CollectionViewAdapter {
    
    /// collectionView의 스크롤 방향
    ///
    /// 현재 collectionViewLayout이 UICollectionViewCompositionalLayout이면
    /// 해당 layout configuration의 scrollDirection을 사용하고,
    /// 그렇지 않으면 기본값으로 vertical을 사용한다.
    private var scrollDirection: UICollectionView.ScrollDirection {
        let layout = collectionView?.collectionViewLayout as? UICollectionViewCompositionalLayout
        return layout?.configuration.scrollDirection ?? .vertical
    }
    
    /// collectionView가 끝에 도달했는지 직접 확인하고,
    /// 필요하면 ReachedEndEvent를 발생시킨다.
    ///
    /// 사용자가 드래그 중이거나 터치 추적 중이 아닐 때만 검사한다.
    /// 기본적으로 끝 도달 여부는 scrollViewWillEndDragging에서 처리되지만,
    /// 드래그 없이 스크롤 위치가 변하는 경우를 보완하기 위해 사용된다.
    @MainActor
    private func manuallyCheckReachedEndEventIfNeeded() {
        guard let collectionView,
              collectionView.isDragging == false,
              collectionView.isTracking == false
        else {
            return
        }
        
        triggerReachedEndEventIfNeeded(contentOffset: collectionView.contentOffset)
    }
    
    /// 현재 contentOffset을 기준으로 끝 근처에 도달했는지 판단하고,
    /// 조건을 만족하면 ReachedEndEvent를 발생시킨다.
    ///
    /// - Parameter contentOffset: 현재 스크롤 위치
    ///
    /// 스크롤 방향이 vertical인지 horizontal인지에 따라
    /// viewLength, contentLength, offset을 다르게 계산한다.
    /// contentLength가 viewLength보다 작으면 즉시 이벤트를 발생시키고,
    /// 그렇지 않으면 남은 거리를 계산하여 triggerDistance 이하일 때 이벤트를 발생시킨다.
    @MainActor
    private func triggerReachedEndEventIfNeeded(contentOffset: CGPoint) {
        guard
            let event = list?.event(for: ReachedEndEvent.self),
            let collectionView,
            collectionView.bounds.isEmpty == false
        else {
            return
        }
        
        let viewLength: CGFloat
        let contentLength: CGFloat
        let offset: CGFloat
        
        switch scrollDirection {
        case .vertical:
            viewLength = collectionView.bounds.size.height
            contentLength = collectionView.contentSize.height
            offset = contentOffset.y
        default:
            viewLength = collectionView.bounds.size.width
            contentLength = collectionView.contentSize.width
            offset = contentOffset.x
        }
        
        let triggerDistance: CGFloat = {
            switch event.offset {
            case .absolute(let offset):
                return offset
            case .relativeToContainerSize(let multiplier):
                return viewLength * multiplier
            }
        }()
        
        let remainingDistance = contentLength - viewLength - offset
        if contentLength < viewLength || remainingDistance <= triggerDistance {
            event.handler(.init())
        }
    }
}

// MARK: - CollectionViewLayoutAdapterDataSource
extension CollectionViewAdapter: CollectionViewLayoutAdapterDataSource {
    
    /// index에 해당하는 Section을 반환한다.
    ///
    /// - Parameter index: 가져올 Section의 index
    /// - Returns: 해당 index의 Section. 없으면 nil
    @MainActor
    public func sectionItem(at index: Int) -> Section? {
        list?.sections[safe: index]
    }
    
    /// 컴포넌트 사이즈 캐시 저장소를 반환한다.
    ///
    /// - Returns: 셀 / 헤더 / 푸터 사이즈를 저장하는 ComponentSizeStorage
    @MainActor
    public func sizeStorage() -> ComponentSizeStorage {
        componentSizeStorage
    }
}


// MARK: - UICollectionViewDelegate
extension CollectionViewAdapter: UICollectionViewDelegate {
    
    /// 셀이 선택되었을 때 호출된다.
    ///
    /// 해당 indexPath의 Cell을 찾고,
    /// Cell에 등록된 DidSelectEvent가 있다면 이벤트 핸들러를 실행한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = item(at: indexPath) else {
            return
        }
        
        item.event(for: DidSelectEvent.self)?.handler(
            .init(
                indexPath: indexPath,
                anyComponent: item.component
            )
        )
    }
    
    /// 셀이 화면에 표시되기 직전에 호출된다.
    ///
    /// 해당 Cell의 WillDisplayEvent가 있다면,
    /// indexPath, component, 실제 렌더링된 content를 함께 전달한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let item = item(at: indexPath) else {
            return
        }
        
        item.event(for: WillDisplayEvent.self)?.handler(
            .init(
                indexPath: indexPath,
                anyComponent: item.component,
                content: (cell as? ComponentRenderable)?.renderedContent
            )
        )
    }
    
    /// 셀이 화면에서 사라진 뒤 호출된다.
    ///
    /// 해당 Cell의 DidEndDisplayingEvent가 있다면,
    /// indexPath, component, 실제 렌더링된 content를 함께 전달한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard let item = item(at: indexPath) else {
            return
        }
        
        item.event(for: DidEndDisplayingEvent.self)?.handler(
            .init(
                indexPath: indexPath,
                anyComponent: item.component,
                content: (cell as? ComponentRenderable)?.renderedContent
            )
        )
    }
    
    /// 헤더 또는 푸터 supplementary view가 화면에 표시되기 직전에 호출된다.
    ///
    /// elementKind에 따라 header 또는 footer를 구분하고,
    /// 각각의 WillDisplayEvent가 있다면 이벤트를 전달한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplaySupplementaryView view: UICollectionReusableView,
        forElementKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard let section = sectionItem(at: indexPath.section) else {
            return
        }
        
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = section.header else {
                return
            }
            
            header.event(for: WillDisplayEvent.self)?.handler(
                .init(
                    indexPath: indexPath,
                    anyComponent: header.component,
                    content: (view as? ComponentRenderable)?.renderedContent
                )
            )
            
        case UICollectionView.elementKindSectionFooter:
            guard let footer = section.footer else {
                return
            }
            
            footer.event(for: WillDisplayEvent.self)?.handler(
                .init(
                    indexPath: indexPath,
                    anyComponent: footer.component,
                    content: (view as? ComponentRenderable)?.renderedContent
                )
            )
            
        default:
            return
        }
    }
    
    /// 헤더 또는 푸터 supplementary view가 화면에서 사라진 뒤 호출된다.
    ///
    /// elementKind에 따라 header 또는 footer를 구분하고,
    /// 각각의 DidEndDisplayingEvent가 있다면 이벤트를 전달한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplayingSupplementaryView view: UICollectionReusableView,
        forElementOfKind elementKind: String,
        at indexPath: IndexPath
    ) {
        guard let section = sectionItem(at: indexPath.section) else {
            return
        }
        
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = section.header else {
                return
            }
            
            header.event(for: DidEndDisplayingEvent.self)?.handler(
                .init(
                    indexPath: indexPath,
                    anyComponent: header.component,
                    content: (view as? ComponentRenderable)?.renderedContent
                )
            )
            
        case UICollectionView.elementKindSectionFooter:
            guard let footer = section.footer else {
                return
            }
            
            footer.event(for: DidEndDisplayingEvent.self)?.handler(
                .init(
                    indexPath: indexPath,
                    anyComponent: footer.component,
                    content: (view as? ComponentRenderable)?.renderedContent
                )
            )
            
        default:
            return
        }
    }
    
    /// 셀이 highlight 상태가 되었을 때 호출된다.
    ///
    /// 터치 다운 등으로 셀이 눌린 상태가 되면 HighlightEvent를 전달한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        didHighlightItemAt indexPath: IndexPath
    ) {
        guard let item = item(at: indexPath) else {
            return
        }
        
        item.event(for: HighlightEvent.self)?.handler(
            .init(
                indexPath: indexPath,
                anyComponent: item.component,
                content: (collectionView.cellForItem(at: indexPath) as? ComponentRenderable)?.renderedContent
            )
        )
    }
    
    /// 셀의 highlight 상태가 해제되었을 때 호출된다.
    ///
    /// 터치가 끝나거나 취소되어 셀이 더 이상 눌린 상태가 아니면 UnhighlightEvent를 전달한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        didUnhighlightItemAt indexPath: IndexPath
    ) {
        guard let item = item(at: indexPath) else {
            return
        }
        
        item.event(for: UnhighlightEvent.self)?.handler(
            .init(
                indexPath: indexPath,
                anyComponent: item.component,
                content: (collectionView.cellForItem(at: indexPath) as? ComponentRenderable)?.renderedContent
            )
        )
    }
}

// MARK: - UIScrollViewDelegate
extension CollectionViewAdapter {
    
    /// 스크롤이 발생할 때 호출된다.
    ///
    /// DidScrollEvent를 전달하고,
    /// 필요하면 끝 도달 이벤트도 직접 검사한다.
    @MainActor
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView else {
            return
        }
        
        list?.event(for: DidScrollEvent.self)?.handler(
            .init(
                collectionView: collectionView
            )
        )
        
        manuallyCheckReachedEndEventIfNeeded()
    }
    
    /// 사용자가 드래그를 시작할 때 호출된다.
    ///
    /// WillBeginDraggingEvent를 전달한다.
    @MainActor
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let collectionView else {
            return
        }
        
        list?.event(for: WillBeginDraggingEvent.self)?.handler(
            .init(
                collectionView: collectionView
            )
        )
    }
    
    /// 사용자가 드래그를 끝내기 직전에 호출된다.
    ///
    /// velocity와 targetContentOffset을 함께 전달하며,
    /// targetContentOffset 기준으로 끝 도달 여부도 검사한다.
    @MainActor
    public func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        guard let collectionView else {
            return
        }
        
        list?.event(for: WillEndDraggingEvent.self)?.handler(
            .init(
                collectionView: collectionView,
                velocity: velocity,
                targetContentOffset: targetContentOffset
            )
        )
        
        triggerReachedEndEventIfNeeded(contentOffset: targetContentOffset.pointee)
    }
    
    /// 사용자가 드래그를 끝냈을 때 호출된다.
    ///
    /// 감속 여부(decelerate)를 함께 전달한다.
    @MainActor
    public func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        guard let collectionView else {
            return
        }
        
        list?.event(for: DidEndDraggingEvent.self)?.handler(
            .init(
                collectionView: collectionView,
                decelerate: decelerate
            )
        )
    }
    
    /// scrollView가 맨 위로 스크롤되었을 때 호출된다.
    ///
    /// DidScrollToTopEvent를 전달한다.
    @MainActor
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        guard let collectionView else {
            return
        }
        
        list?.event(for: DidScrollToTopEvent.self)?.handler(
            .init(
                collectionView: collectionView
            )
        )
    }
    
    /// scrollView가 감속을 시작할 때 호출된다.
    ///
    /// WillBeginDeceleratingEvent를 전달한다.
    @MainActor
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard let collectionView else {
            return
        }
        
        list?.event(for: WillBeginDeceleratingEvent.self)?.handler(
            .init(
                collectionView: collectionView
            )
        )
    }
    
    /// scrollView의 감속이 끝났을 때 호출된다.
    ///
    /// DidEndDeceleratingEvent를 전달한다.
    @MainActor
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let collectionView else {
            return
        }
        
        list?.event(for: DidEndDeceleratingEvent.self)?.handler(
            .init(
                collectionView: collectionView
            )
        )
    }
    
    /// scrollView가 맨 위로 스크롤되어도 되는지 결정한다.
    ///
    /// ShouldScrollToTopEvent가 있으면 해당 handler 결과를 사용하고,
    /// 없으면 기본값으로 true를 반환한다.
    @MainActor
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard let collectionView else {
            return true
        }
        
        return list?.event(for: ShouldScrollToTopEvent.self)?.handler(
            .init(
                collectionView: collectionView
            )
        ) ?? true
    }
}


// MARK: - UICollectionViewDataSourcePrefetching
extension CollectionViewAdapter: UICollectionViewDataSourcePrefetching {
    
    /// 지정된 indexPath의 아이템들이 곧 필요할 것으로 예상될 때 호출된다.
    ///
    /// 해당 item의 component가 ComponentResourcePrefetchable을 지원하면
    /// 등록된 prefetchingPlugins를 실행하고,
    /// 반환된 AnyCancellable들을 indexPath 기준으로 저장한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        for indexPath in indexPaths {
            guard prefetchingIndexPathOperations[indexPath] == nil else {
                continue
            }
            
            guard let item = item(at: indexPath),
                  let prefetchableComponent = item.component.as(ComponentResourcePrefetchable.self)
            else {
                continue
            }
            
            prefetchingIndexPathOperations[indexPath] = prefetchingPlugins.compactMap {
                $0.prefetch(with: prefetchableComponent)
            }
        }
    }
    
    /// 프리패칭이 더 이상 필요하지 않을 때 호출된다.
    ///
    /// indexPath에 저장된 AnyCancellable들을 꺼내 cancel을 호출하여
    /// 진행 중인 프리패칭 작업을 취소한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath]
    ) {
        for indexPath in indexPaths {
            prefetchingIndexPathOperations.removeValue(forKey: indexPath)?.forEach {
                $0.cancel()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension CollectionViewAdapter: UICollectionViewDataSource {
    
    @MainActor
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        list?.sections.count ?? 0
    }

    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        sectionItem(at: section)?.cells.count ?? 0
    }
    
    // MARK: - Required
    /// 특정 indexPath에 해당하는 cell을 생성하고 반환한다.
    ///
    /// item의 component.reuseIdentifier로 cell을 dequeue하고,
    /// UICollectionViewComponentCell로 캐스팅한 뒤 component를 렌더링한다.
    ///
    /// cell의 사이즈가 계산되면 componentSizeStorage에 저장되며,
    /// 프리패칭 작업이 있었다면 cell.cancellables로 넘겨 셀 생명주기에서 관리한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let item = item(at: indexPath) else {
            return UICollectionViewCell()
        }
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: item.component.reuseIdentifier,
            for: indexPath
        ) as? UICollectionViewComponentCell
        else {
            return UICollectionViewCell()
        }
        
        cell.onSizeChanged = { [weak self] size in
            self?.componentSizeStorage.setCellSize(
                (size, item.component.item),
                for: item.id
            )
        }
        
        cell.cancellables = prefetchingIndexPathOperations.removeValue(forKey: indexPath)
        cell.render(component: item.component)
        
        return cell
    }
    
    /// 헤더 또는 푸터 supplementary view를 생성하고 반환한다.
    ///
    /// kind가 UICollectionView.elementKindSectionHeader이면 header를,
    /// UICollectionView.elementKindSectionFooter이면 footer를 처리한다.
    ///
    /// 각각 component를 렌더링하고,
    /// 사이즈가 계산되면 componentSizeStorage에 header/footer size로 저장한다.
    @MainActor
    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let section = sectionItem(at: indexPath.section),
                  let header = section.header
            else {
                return UICollectionReusableView()
            }
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: header.component.reuseIdentifier,
                for: indexPath
            ) as? UICollectionComponentReusableView
            else {
                return UICollectionReusableView()
            }
            
            headerView.onSizeChanged = { [weak self] size in
                self?.componentSizeStorage.setHeaderSize(
                    (size, header.component.item),
                    for: section.id
                )
            }
            
            headerView.render(component: header.component)
            
            return headerView
            
        case UICollectionView.elementKindSectionFooter:
            guard let section = sectionItem(at: indexPath.section),
                  let footer = section.footer
            else {
                return UICollectionReusableView()
            }
            
            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: footer.component.reuseIdentifier,
                for: indexPath
            ) as? UICollectionComponentReusableView
            else {
                return UICollectionReusableView()
            }
            
            footerView.onSizeChanged = { [weak self] size in
                self?.componentSizeStorage.setFooterSize(
                    (size, footer.component.item),
                    for: section.id
                )
            }
            
            footerView.render(component: footer.component)
            
            return footerView
            
        default:
            return UICollectionReusableView()
        }
    }
}

extension CollectionViewAdapter {

    private func configureRefreshControlAppearance() {
        guard
            let refreshControl = collectionView?.refreshControl,
            let appearance = configuration.refreshControlAppearance
        else {
            return
        }
        
        let indicator = appearance.indicator
        let image = indicator.tintColor == nil
            ? indicator.image
            : indicator.image.withRenderingMode(.alwaysTemplate)
        
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if let tintColor = indicator.tintColor {
            imageView.tintColor = tintColor
        }
        
        if let size = indicator.size {
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: size),
                imageView.heightAnchor.constraint(equalToConstant: size)
            ])
        }
        
        refreshControl.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: refreshControl.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: refreshControl.centerYAnchor)
        ])
        
        if let duration = indicator.spinDuration {
            addSpinAnimation(to: imageView, duration: duration)
        }
        
        refreshControl.tintColor = .clear
    }

    private func addSpinAnimation(
        to view: UIView,
        duration: TimeInterval
    ) {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        view.layer.add(animation, forKey: "refresh.spin")
    }

}
