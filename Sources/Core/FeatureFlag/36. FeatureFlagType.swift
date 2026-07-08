//
//  File.swift
//  TurboListKit
//
//  Created by 김동현 on 4/24/26.
//

import Foundation

/// 기능 플래그를 정의합니다.
public enum FeatureFlagType: Equatable {
    
    /// 계산된 뷰 크기를 사용하여 스크롤 성능을 개선합니다.
    /// 자세한 내용은 다음 문서를 참고하세요:
    /// https://developer.apple.com/documentation/uikit/building-high-performance-lists-and-collection-views
    case useCachedViewSize
}
