//
//  File.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import UIKit

/// 이 구조체는 pull-to-refresh(당겨서 새로고침) 이벤트에 대한 정보를 캡슐화하며,
/// 해당 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct PullToRefreshEvent: ListingViewEvent {
    public struct EventContext {}
    
    /// 사용자가 콘텐츠를 아래로 당겨 새로고침을 수행했을 때 호출되는 클로저
    let handler: (EventContext) -> Void
}
