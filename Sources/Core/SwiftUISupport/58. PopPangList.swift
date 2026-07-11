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
    
    public init(
        configuration: CollectionViewAdapterConfiguration = .init(),
        @SectionsBuilder content: () -> [Section]
    ) {
        self.configuration = configuration
        self.list = List(sections: content())
    }
    
    public var body: some View {
        PopPangListRepresentable(
            list: list,
            configuration: configuration
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
}
