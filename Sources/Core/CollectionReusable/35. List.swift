//
//  List.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Foundation

public struct List: ListingViewEventHandler {
    
    /// Section UI를 표현하는 Section 배열
    public var setions: [Section]
    let eventStorage = ListingViewEventStorage()
    
    /// List를 생성하는 초기화 메서드입니다.
    ///
    /// - Parameters:
    ///  - sections: 화면에 표시될 Section 배열
    public init(
        setions: [Section]
    ) {
        self.setions = setions
    }
    
    /// List를 생성하는 초기화 메서드입니다.
    ///
    /// - Parameters:
    ///  - sections: 화면에 표시될 Section 배열을 생성하는 Builder
    public init(
        @SectionsBuilder _ sections: () -> [Section]
    ) {
        self.setions = sections()
    }
}

// MARK: - Event Handler
extension List {
    
    /// 사용자가 콘텐츠를 스크롤할 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: did scroll 이벤트에 대한 콜백 핸들러
    @MainActor
    public func didScroll(
    _ handler: @escaping (DidScrollEvent.EventContext) -> Void
    ) -> Self {
        registerEvent(DidScrollEvent(handler: handler))
    }
    
    /// 사용자가 pull to refresh를 수행했을 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: pull to refresh 이벤트에 대한 콜백 핸들러
    @MainActor
    public func onRefresh(
        _ handler: @escaping (PullToRefreshEvent.EventContext) -> Void
    ) -> Self {
        registerEvent(PullToRefreshEvent(handler: handler))
    }
    
    /// 사용자가 콘텐츠의 끝 근처까지 스크롤했을 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///   - offset: 이벤트를 트리거하는 콘텐츠 끝 기준 오프셋. 기본값은 콘텐츠 높이의 2배
    ///   - handler: reached end 이벤트에 대한 콜백 핸들러
    /// - Returns: 이벤트 핸들러가 등록된 새로운 `List`
    @MainActor
    public func onReachEnd(
        offsetFromEnd offset: ReachedEndEvent.OffsetFromEnd = .relativeToContainerSize(multiplier: 2.0),
        _ handler: @escaping (ReachedEndEvent.EventContext) -> Void
    ) -> Self {
        registerEvent(
            ReachedEndEvent(
            offset: offset,
            handler: handler
            )
        )
    }
    
    /// scrollView가 콘텐츠 스크롤을 시작하려고 할 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: will begin dragging 이벤트에 대한 콜백 핸들러
    @MainActor
    public func willBeginDragging(_ handler: @escaping (WillBeginDraggingEvent.EventContext) -> Void) -> Self {
        registerEvent(WillBeginDraggingEvent(handler: handler))
    }
    
    /// 사용자가 콘텐츠 스크롤을 마치기 직전에 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: will end dragging 이벤트에 대한 콜백 핸들러
    @MainActor
    public func willEndDragging(_ handler: @escaping (WillEndDraggingEvent.EventContext) -> Void) -> Self {
        registerEvent(WillEndDraggingEvent(handler: handler))
    }
    
    /// 사용자가 콘텐츠 스크롤을 마쳤을 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: did end dragging 이벤트에 대한 콜백 핸들러
    @MainActor
    public func didEndDragging(_ handler: @escaping (DidEndDraggingEvent.EventContext) -> Void) -> Self {
        registerEvent(DidEndDraggingEvent(handler: handler))
    }
    
    /// scrollView가 콘텐츠의 맨 위로 스크롤되었을 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: did scroll to top 이벤트에 대한 콜백 핸들러
    @MainActor
    public func didScrollToTop(_ handler: @escaping (DidScrollToTopEvent.EventContext) -> Void) -> Self {
        registerEvent(DidScrollToTopEvent(handler: handler))
    }
    
    /// scrollView가 감속 스크롤을 시작할 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: will begin decelerating 이벤트에 대한 콜백 핸들러
    @MainActor
    public func willBeginDecelerating(_ handler: @escaping (WillBeginDeceleratingEvent.EventContext) -> Void) -> Self {
        registerEvent(WillBeginDeceleratingEvent(handler: handler))
    }
    
    /// scrollView의 감속 스크롤이 종료되었을 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: did end decelerating 이벤트에 대한 콜백 핸들러
    @MainActor
    public func didEndDecelerating(_ handler: @escaping (DidEndDeceleratingEvent.EventContext) -> Void) -> Self {
        registerEvent(DidEndDeceleratingEvent(handler: handler))
    }
    
    /// scrollView가 콘텐츠의 맨 위로 스크롤해야 하는지 여부를 결정할 때 호출되는 콜백 핸들러를 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: shouldScrollToTop 이벤트에 대한 콜백 핸들러
    @MainActor
    public func shouldScrollToTop(_ handler: @escaping (ShouldScrollToTopEvent.EventContext) -> Bool) -> Self {
        registerEvent(ShouldScrollToTopEvent(handler: handler))
    }
}
