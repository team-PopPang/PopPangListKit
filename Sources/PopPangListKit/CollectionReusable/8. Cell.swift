//
//  Cell.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import Foundation
import DifferenceKit

/// DifferenceKit과 셀 사이즈 캐시에서 사용하는 Section 범위의 Cell 식별자입니다.
///
/// 외부에 노출되는 `Cell.id`는 도메인 식별자 의미를 그대로 유지하고,
/// 내부에서만 Section ID와 조합해 서로 다른 Section의 같은 Cell ID를 구분합니다.
struct SectionScopedCellIdentity: Hashable {
    let sectionID: AnyHashable
    let cellID: AnyHashable
}

public struct Cell: Identifiable, @MainActor ListingViewEventHandler {
    
    /// Cell을 식별하기 위한 ID
    public let id: AnyHashable
    
    /// 셀을 구성하는 타입 소거된 Component
    public let component: AnyComponent
    
    /// 이벤트 저장소
    let eventStorage = ListingViewEventStorage()

    /// DifferenceKit과 셀 사이즈 캐시에서 사용하는 내부 식별자
    private var sectionScopedIdentity: SectionScopedCellIdentity?
    
    public init(id: some Hashable, component: some Component) {
        self.id = id
        self.component = AnyComponent(component: component)
        self.sectionScopedIdentity = nil
    }
}

extension Cell {

    /// Section에 포함되지 않은 Cell은 기존처럼 raw ID를 사용합니다.
    /// Section이 Cell을 소유하면 `(sectionID, cellID)`로 범위가 지정됩니다.
    var internalIdentity: AnyHashable {
        sectionScopedIdentity.map(AnyHashable.init) ?? id
    }

    func scoped(to sectionID: AnyHashable) -> Self {
        var copy = self
        copy.sectionScopedIdentity = SectionScopedCellIdentity(
            sectionID: sectionID,
            cellID: id
        )
        return copy
    }
}

extension Cell: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Cell, rhs: Cell) -> Bool {
        lhs.id == rhs.id && lhs.component == rhs.component
    }
}

extension Cell: Differentiable {
    public var differenceIdentifier: AnyHashable {
        internalIdentity
    }
    
    public func isContentEqual(to source: Cell) -> Bool {
        self == source
    }
}

// MARK: - Event Handler
extension Cell {
    
    /// 셀이 선택되었을 때 호출되는 콜백을 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: 선택 이벤트 콜백
    @MainActor
    public func didSelect(_ handler: @escaping (DidSelectEvent.EventContext) -> Void) -> Self {
        registerEvent(DidSelectEvent(handler: handler))
    }
    
    /// 셀이 화면에 표시되기 직전에 호출되는 콜백을 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: willDisplay 이벤트 콜백
    @MainActor
    public func willDisplay(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
        registerEvent(WillDisplayEvent(handler: handler))
    }
    
    /// 셀이 화면에서 제거(사라짐)되었을 때 호출되는 콜백을 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: didEndDisplay 이벤트 콜백
    @MainActor
    public func didEndDisplay(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
        registerEvent(DidEndDisplayingEvent(handler: handler))
    }
    
    /// 셀이 하이라이트(눌림 상태) 되었을 때 호출되는 콜백을 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: highlight 이벤트 콜백
    @MainActor
    public func onHighlight(_ handler: @escaping (HighlightEvent.EventContext) -> Void) -> Self {
        registerEvent(HighlightEvent(handler: handler))
    }
    
    /// 셀이 하이라이트 해제되었을 때 호출되는 콜백을 등록합니다.
    ///
    /// - Parameters:
    ///  - handler: unhighlight 이벤트 콜백
    @MainActor
    public func onUnhighlight(_ handler: @escaping (UnhighlightEvent.EventContext) -> Void) -> Self {
        registerEvent(UnhighlightEvent(handler: handler))
    }
}
