//
//  RemoteImagePrefetchingPlugin.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import Combine
import Foundation

/// CollectionViewPrefetchingPlugin 프로토콜의 구체적인 구현 클래스
/// RemoteImagePrefetching을 따르는 객체를 사용해 원격 이미지를 미리 로딩(prefetch)한다
public final class RemoteImagePrefetchingPlugin: CollectionViewPrefetchingPlugin {
    
    /// 실제 이미지 프리패칭을 수행하는 객체
    private let remoteImagePrefetcher: RemoteImagePrefetching
    
    /// RemoteImagePrefetchingPlugin 초기화
    ///
    /// - Parameter remoteImagePrefetcher:
    ///   원격 이미지 프리패칭을 수행할 RemoteImagePrefetching 구현체
    public init(remoteImagePrefetcher: RemoteImagePrefetching) {
        self.remoteImagePrefetcher = remoteImagePrefetcher
    }
    
    /// 주어진 컴포넌트의 리소스를 미리 로딩한다
    ///
    /// - Parameter component: 프리패치가 필요한 컴포넌트
    /// - Returns: 필요 시 프리패치 작업을 취소할 수 있는 AnyCancellable (optional)
    public func prefetch(
        with component: ComponentResourcePrefetchable
    ) -> AnyCancellable? {
        // 해당 컴포넌트가 "이미지 프리패치 대상"이 아니라면 아무 것도 하지 않음
        guard let component = component as? ComponentRemoteImagePrefetchable else {
            return nil
        }
        
        // 컴포넌트가 가지고 있는 이미지 URL들을 순회하면서 프리패치 실행
        // 각 작업의 식별자(UUID)를 수집
        let uuids = component.remoteImageURLs.compactMap {
            remoteImagePrefetcher.prefetchImage(url: $0)
        }
        
        // AnyCancellable 반환
        // → 이 객체가 해제되거나 cancel되면 모든 프리패치 작업 취소
        return AnyCancellable { [remoteImagePrefetcher] in
            for uuid in uuids {
                remoteImagePrefetcher.cancelTask(uuid: uuid)
            }
        }
    }
}
