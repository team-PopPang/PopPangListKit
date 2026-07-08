//
//  WillDisplayEvent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

/// 이 구조체는 willDisplay 이벤트에 대한 정보를 캡슐화하며,
/// willDisplay 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct WillDisplayEvent: ListingViewEvent {
    
    public struct EventContext {
        
        /// 추가될 뷰의 indexPath
        public let indexPath: IndexPath
        
        /// 추가될 뷰가 가지고 있는 컴포넌트
        public let anyComponent: AnyComponent
        
        /// 추가될 뷰가 가지고 있는 실제 콘틴츠 (UIView)
        public let content: UIView?
    }
    
    /// 뷰가 화면에 추가될 때 호출되는 클로저
    let handler: (EventContext) -> Void
}
