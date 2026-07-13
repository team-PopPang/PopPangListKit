//
//  DidSelectEvent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Foundation

/// 이 구조체는 셀 선택(selection) 이벤트에 대한 정보를 캡슐화하며,
/// 선택 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct DidSelectEvent: ListingViewEvent {
    
    public struct EventContext {
        
        /// 선택된 셀의 indexPath
        public let indexPath: IndexPath
        
        /// 선택된 셀이 가지고 있는 컴포넌트
        public let anyComponent: AnyComponent
    }
    
    /// 셀이 선택되었을 때 호출되는 클로저
    let handler: (EventContext) -> Void
}
