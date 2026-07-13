//
//  ListingViewEvent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Foundation

/// 이벤트를 정의하는 프로토콜
protocol ListingViewEvent {
    
    /// 이벤트 입력 타입
    associatedtype Input
    
    /// 이벤트 출력 타입
    associatedtype Output
    
    /// 이벤트를 식별하기 위한 ID
    var id: AnyHashable { get }
    
    /// 실제 이벤트 처리 로직 (핸들러)
    var handler: (Input) -> Output { get }
}

extension ListingViewEvent {
    /// 기본 ID 구현 (타입 이름 기반)
    var id: AnyHashable {
        String(reflecting: Self.self)
    }
}
