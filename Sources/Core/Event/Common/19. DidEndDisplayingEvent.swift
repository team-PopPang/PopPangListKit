//
//  DidEndDisplayingEvent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

/// 이 구조체는 didEndDisplaying 이벤트 정보를 캡슐화하며,
/// 해당 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct DidEndDisplayingEvent: ListingViewEvent {

    public struct EventContext {
        
        /// 화면에서 제거된 뷰의 indexPath
        public let indexPath: IndexPath
        
        /// 제거된 뷰가 가지고 있던 Component
        public let anyComponent: AnyComponent
        
        /// 제거된 뷰가 가지고 있던 실제 콘텐츠(UIView)
        public let content: UIView?
    }
    
    /// 뷰가 화면에서 제거될 때 호출되는 클로저
    let handler: (EventContext) -> Void
}
