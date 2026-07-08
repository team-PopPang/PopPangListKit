//
//  File.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import Foundation

/// 원격 이미지를 미리 로딩(prefetch)하기 위한 프로토콜
public protocol RemoteImagePrefetching {
    /// 주어진 URL의 이미지를 미리 로딩한다.
    ///
    /// - Parameter url: 미리 로딩할 이미지의 URL
    /// - Returns: 프리패치 작업을 식별하는 UUID
    ///            (필요 시 해당 작업을 취소하는 데 사용됨)
    func prefetchImage(url: URL) -> UUID?
    
    /// 주어진 UUID에 해당하는 프리패치 작업을 취소한다.
    ///
    /// - Parameter uuid: 취소할 프리패치 작업의 UUID
    func cancelTask(uuid: UUID)
}
