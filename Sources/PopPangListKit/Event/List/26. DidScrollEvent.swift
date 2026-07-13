//
//  File.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import UIKit

/// 이 구조체는 스크롤(didScroll) 이벤트에 대한 정보를 캡슐화하며,
/// 해당 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct DidScrollEvent: ListingViewEvent {
    
    public struct EventContext {
        
        /// 스크롤이 발생한 UICollectionView 객체
        public let collectionView: UICollectionView
    }
    
    /// 사용자가 컬렉션 뷰의 콘텐츠를 스크롤할 때마다 호출되는 클로저
    let handler: (EventContext) -> Void
}
