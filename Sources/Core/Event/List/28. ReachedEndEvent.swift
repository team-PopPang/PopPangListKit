//
//  File.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import Foundation

/// 사용자가 리스트 뷰의 끝에 도달했을 때 발생하는 이벤트
public struct ReachedEndEvent: ListingViewEvent {
    
    /// `ReachedEndEvent`에 대한 컨텍스트
    public struct EventContext {}
    
    /// 이벤트를 트리거할 “리스트 끝 기준 오프셋”을 정의
    public enum OffsetFromEnd {
        /// 콘텐츠 뷰 높이의 배수 범위 내로 스크롤되었을 때 이벤트 발생
        case relativeToContainerSize(multiplier: CGFloat)
        
        /// 리스트 끝에서부터 특정 절대 거리(포인트) 이내로 스크롤되었을 때 이벤트 발생
        case absolute(CGFloat)
    }
    
    /// 이벤트를 발생시킬 리스트 끝 기준 오프셋
    let offset: OffsetFromEnd
    
    /// 이벤트가 발생했을 때 호출되는 핸들러
    let handler: (EventContext) -> Void
}
