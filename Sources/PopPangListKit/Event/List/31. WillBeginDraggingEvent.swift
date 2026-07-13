//
//  File.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import UIKit

/// 이 구조체는 드래그 시작(willBeginDragging) 이벤트에 대한 정보를 캡슐화하며,
/// 해당 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct WillBeginDraggingEvent: ListingViewEvent {
    
    public struct EventContext {
        
        /// 콘텐츠 뷰의 스크롤이 시작되기 직전의 UICollectionView 객체
        public let collectionView: UICollectionView
    }
    
    /// 컬렉션 뷰가 스크롤을 시작하려고 할 때 호출되는 클로저
    let handler: (EventContext) -> Void
}
