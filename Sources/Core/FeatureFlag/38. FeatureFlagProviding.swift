//
//  File.swift
//  TurboListKit
//
//  Created by 김동현 on 4/24/26.
//

import Foundation

/// 기능 플래그를 제공하기 위한 프로토콜입니다.
public protocol FeatureFlagProviding {
    
    /// 기능 플래그 배열을 반환합니다.
    ///
    /// - Returns: `FeatureFlagItem` 배열
    func featureFlags() -> [FeatureFlagItem]
}

extension FeatureFlagProviding {
    
    /// 특정 기능 플래그가 활성화되어 있는지 여부를 반환합니다.
    ///
    /// - Parameters:
    ///  - type: 확인할 기능 플래그 타입
    /// - Returns: 해당 기능 플래그가 활성화되어 있으면 true, 아니면 false
    func isEnabled(for type: FeatureFlagType) -> Bool {
        return featureFlags()
            .first(where: { $0.type == type })?
            .isEnabled ?? false
    }
}
