//
//  File.swift
//  TurboListKit
//
//  Created by 김동현 on 4/24/26.
//

import Foundation

/// 기본 기능 플래그 제공자입니다.
final class DefaultFeatureFlagProvider: FeatureFlagProviding {
    
    /// 기능 플래그 배열을 반환합니다.
    ///
    /// - Returns: 기본값으로 빈 배열을 반환합니다 (활성화된 기능 없음)
    func featureFlags() -> [FeatureFlagItem] {
        return []
    }
}
