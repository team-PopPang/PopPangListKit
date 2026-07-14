//
//  PopPangList.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/11/26.
//

import SwiftUI

@MainActor
public struct PopPangList: View {
    private var list: List
    private let configuration: CollectionViewAdapterConfiguration
    private let prefetchingPlugins: [CollectionViewPrefetchingPlugin]
    
    public init(
        configuration: CollectionViewAdapterConfiguration = .init(
            enablesReconfigureItems: true
        ),
        prefetchingPlugins: [CollectionViewPrefetchingPlugin] = [],
        @SectionsBuilder content: () -> [Section]
    ) {
        self.configuration = configuration
        self.prefetchingPlugins = prefetchingPlugins
        self.list = List(sections: content())
    }
    
    public var body: some View {
        PopPangListRepresentable(
            list: list,
            configuration: configuration,
            prefetchingPlugins: prefetchingPlugins
        )
        // .ignoresSafeArea(.container, edges: [])
    }
}

// MARK: - Core List modifiers
extension PopPangList {
    public func onRefresh(
        _ handler: @escaping (PullToRefreshEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        copy.list = copy.list.onRefresh(handler)
        return copy
    }

    public func onReachEnd(
        offsetFromEnd offset: ReachedEndEvent.OffsetFromEnd =
            .relativeToContainerSize(multiplier: 2),
        _ handler: @escaping (ReachedEndEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        copy.list = copy.list.onReachEnd(
            offsetFromEnd: offset,
            handler
        )
        return copy
    }

    public func didScroll(
        _ handler: @escaping (DidScrollEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        copy.list = copy.list.didScroll(handler)
        return copy
    }

    public func didEndDecelerating(
        _ handler: @escaping (
            DidEndDeceleratingEvent.EventContext
        ) -> Void
    ) -> Self {
        var copy = self
        copy.list = copy.list.didEndDecelerating(handler)
        return copy
    }

    public func willBeginDragging(
        _ handler: @escaping (WillBeginDraggingEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        copy.list = copy.list.willBeginDragging(handler)
        return copy
    }

    public func willEndDragging(
        _ handler: @escaping (WillEndDraggingEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        copy.list = copy.list.willEndDragging(handler)
        return copy
    }

    public func didEndDragging(
        _ handler: @escaping (DidEndDraggingEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        copy.list = copy.list.didEndDragging(handler)
        return copy
    }

    public func didScrollToTop(
        _ handler: @escaping (DidScrollToTopEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        copy.list = copy.list.didScrollToTop(handler)
        return copy
    }

    public func willBeginDecelerating(
        _ handler: @escaping (WillBeginDeceleratingEvent.EventContext) -> Void
    ) -> Self {
        var copy = self
        copy.list = copy.list.willBeginDecelerating(handler)
        return copy
    }

    public func shouldScrollToTop(
        _ handler: @escaping (ShouldScrollToTopEvent.EventContext) -> Bool
    ) -> Self {
        var copy = self
        copy.list = copy.list.shouldScrollToTop(handler)
        return copy
    }
}
