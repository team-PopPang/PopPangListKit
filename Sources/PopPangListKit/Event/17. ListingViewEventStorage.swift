//
//  ListingViewEventStorage.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Foundation

/// 이벤트를 저장하는 저장소
final class ListingViewEventStorage {
    
    /// 이벤트 저장용 딕셔너리(id기반)
    private var source: [AnyHashable: Any] = [:]
    
    /// 특정 타입의 이벤트 조회
    @MainActor
    func event<E: ListingViewEvent>(for type: E.Type) -> E? {
        source[String(reflecting: type)] as? E
    }
    
    /// 이벤트 등록
    @MainActor
    func register(_ event: some ListingViewEvent) {
        source[event.id] = event
    }
}
