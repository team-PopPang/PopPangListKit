//
//  DidEndDraggingEvent.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import UIKit

/// 이 구조체는 드래그 종료(didEndDragging) 이벤트에 대한 정보를 캡슐화하며,
/// 해당 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct DidEndDraggingEvent: ListingViewEvent {
    
    /**
     if decelerate == false {
         // 이미 멈췄으니까 여기서 바로 처리
     } else {
         // 아직 움직이는 중 → DidEndDecelerating에서 처리
     }
     */
    public struct EventContext {
        
        /// 사용자가 터치를 끝낸 UICollectionView 객체
        public let collectionView: UICollectionView
        
        /// 드래그 종료 후 스크롤이 계속 이어지는지 여부 (감속 여부)
        ///
        /// true이면, 손을 뗀 이후에도 관성으로 스크롤이 계속 진행됨 (decelerating 상태)
        /// false이면, 손을 떼는 즉시 스크롤이 멈춤
        public let decelerate: Bool
    }
    
    /// 사용자가 콘텐츠 스크롤(드래그)을 마쳤을 때 호출되는 클로저
    let handler: (EventContext) -> Void
}
