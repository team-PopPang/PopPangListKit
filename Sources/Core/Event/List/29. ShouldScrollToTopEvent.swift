//
//  File.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import UIKit

/// 이 구조체는 shouldScrollToTop 이벤트에 대한 정보를 캡슐화하며,
/// 해당 이벤트를 처리하기 위한 클로저를 포함합니다.
public struct ShouldScrollToTopEvent: ListingViewEvent {
    
    public struct EventContext {
      
      /// 이 정보를 요청하는 UICollectionView 객체
      public let collectionView: UICollectionView
    }

    /// 스크롤 뷰가 콘텐츠의 맨 위로 스크롤해야 하는지를 결정할 때 호출되는 클로저
    let handler: (EventContext) -> Bool
}
