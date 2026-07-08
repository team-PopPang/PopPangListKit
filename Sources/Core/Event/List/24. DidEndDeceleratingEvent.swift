//
//  DidEndDeceleratingEvent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

/// 이 구조체는 스크롤 감속 종료(didEndDecelerating) 이벤트에 대한 정보를 캡슐화하며,
/// 해당 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct DidEndDeceleratingEvent: ListingViewEvent {
    
    public struct EventContext {
        
        /// 콘텐츠 뷰의 스크롤 감속이 진행 중이었던 UICollectionView 객체
        public let collectionView: UICollectionView
    }
    
    /// 컬렉션 뷰의 스크롤 감속이 종료되었을 때 호출되는 클로저
    let handler: (EventContext) -> Void
}
