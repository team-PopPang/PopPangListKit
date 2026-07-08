//
//  HighlightEvent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

/// 이 구조체는 하이라이트(highlight) 이벤트에 대한 정보를 캡슐화하며,
/// 하이라이트 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct HighlightEvent: ListingViewEvent {
    
    public struct EventContext {
        
        /// 하이라이트된 뷰의 indexPath
        public let indexPath: IndexPath
        
        /// 하이라이트된 뷰가 가지고 있는 컴포넌트
        public let anyComponent: AnyComponent
        
        /// 하이라이트된 뷰가 가지고 있는 실제 콘텐츠 (UiView)
        public let content: UIView?
    }
    
    /// 셀이 하이라이트되었을 때 호출되는 클로저
    let handler: (EventContext) -> Void
}
