//
//  File.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import Foundation

/// 사전에 리소스를 미리 로딩(prefetch)해야 하는 컴포넌트를 위한 프로토콜
public protocol ComponentResourcePrefetchable {}

/// 원격 이미지를 미리 로딩(prefetch)해야 하는 컴포넌트를 위한 프로토콜
public protocol ComponentRemoteImagePrefetchable: ComponentResourcePrefetchable {
    /// 미리 로딩해야 하는 원격 이미지 URL 목록
    var remoteImageURLs: [URL] { get }
}
