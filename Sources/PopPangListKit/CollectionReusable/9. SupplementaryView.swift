//
//  SupplementaryView.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import UIKit

public struct SupplementaryView: Equatable, @MainActor ListingViewEventHandler {
    
    /// 보조 뷰의 종류(header, footer 등)
    public let kind: String
    
    /// 보조 뷰를 구성하는 타입 소거된 Component
    public let component: AnyComponent
    
    /// 보조 뷰의 정렬 위치
    public let alignment: NSRectAlignment
    
    /// 이벤트 저장소
    let eventStorage = ListingViewEventStorage()
    
    public init(
        kind: String,
        component: some Component,
        alignment: NSRectAlignment
    ) {
        self.kind = kind
        self.component = AnyComponent(component: component)
        self.alignment = alignment
    }
    
    public static func == (lhs: SupplementaryView, rhs: SupplementaryView) -> Bool {
        lhs.kind == rhs.kind &&
        lhs.component == rhs.component &&
        lhs.alignment == rhs.alignment
    }
}

// MARK: - Event Handler
extension SupplementaryView {
    
    /// 화면에 표시될 때 호출되는 콜백 등록
    ///
    /// - Parameters:
    ///  - handler: 표시 이벤트 콜백
    @MainActor
    public func willDisplay(_ handler: @escaping (WillDisplayEvent.EventContext) -> Void) -> Self {
        registerEvent(WillDisplayEvent(handler: handler))
    }
    
    /// 화면에서 제거될 때 호출되는 콜백 등록
    ///
    /// - Parameters:
    ///  - handler: 제거 이벤트 콜백
    @MainActor
    public func didEndDisplaying(_ handler: @escaping (DidEndDisplayingEvent.EventContext) -> Void) -> Self {
        registerEvent(DidEndDisplayingEvent(handler: handler))
    }
}
