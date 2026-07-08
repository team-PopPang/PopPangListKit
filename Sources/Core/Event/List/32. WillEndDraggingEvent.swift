//
//  File.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import UIKit

/// 이 구조체는 드래그 종료 직전(willEndDragging) 이벤트에 대한 정보를 캡슐화하며,
/// 해당 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct WillEndDraggingEvent: ListingViewEvent {
    
    public struct EventContext {
        
        /// 사용자가 터치를 끝낸 UICollectionView 객체
        public let collectionView: UICollectionView
        
        /// 터치를 놓는 순간의 스크롤 속도 (points per millisecond)
        public let velocity: CGPoint
        
        /// 스크롤이 감속되어 멈출 때의 예상 위치(offset)
        /// 이 값을 변경하면 최종 스크롤 위치를 조정할 수 있음
        public let targetContentOffset: UnsafeMutablePointer<CGPoint>
    }
    
    /// 사용자가 스크롤을 마치기 직전에 호출되는 클로저
    let handler: (EventContext) -> Void
}
