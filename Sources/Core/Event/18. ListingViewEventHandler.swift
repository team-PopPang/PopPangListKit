//
//  ListingViewEventHandler.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Foundation

import Foundation

/// 이벤트를 등록하고 가져오는 기능을 제공하는 프로토콜
protocol ListingViewEventHandler {
    
    /// 이벤트 저장소
    var eventStorage: ListingViewEventStorage { get }
    
    /// 이벤트 등록
    func registerEvent<E: ListingViewEvent>(_ event: E) -> Self
    
    /// 특정 타입의 이벤트 조회
    func event<E: ListingViewEvent>(for type: E.Type) -> E?
}

/// 기본 구현
extension ListingViewEventHandler {
    
    /// 이벤트를 저장소에 등록하고 자기 자신을 반환
    @MainActor
    func registerEvent(_ event: some ListingViewEvent) -> Self {
        eventStorage.register(event)
        return self
    }
    
    /// 특정 이벤트 타입으로 조회
    @MainActor
    func event<E: ListingViewEvent>(for type: E.Type) -> E? {
        eventStorage.event(for: type)
    }
}
