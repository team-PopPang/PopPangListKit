//
//  CollectionViewPrefetchingPlugin.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import Combine
import Foundation

/// CollectionView에서 컴포넌트의 리소스를 비동기로 미리 로딩(prefetch)하기 위한 프로토콜
public protocol CollectionViewPrefetchingPlugin {
    
    /// 컴포넌트가 필요로 하는 리소스를 미리 로딩하는 작업을 수행한다.
    /// 프리패치 작업을 취소할 수 있도록 AnyCancellable? 타입을 반환한다.
    ///
    /// - Parameter component: 리소스 프리패치가 필요한 컴포넌트
    /// - Returns: 필요 시 프리패치 작업을 취소할 수 있는 optional 인스턴스
    func prefetch(with component: ComponentResourcePrefetchable) -> AnyCancellable?
}
