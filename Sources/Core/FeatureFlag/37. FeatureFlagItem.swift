//
//  File.swift
//  TurboListKit
//
//  Created by 김동현 on 4/24/26.
//

import Foundation

/// 기능 플래그 항목을 표현하는 구조체입니다.
public struct FeatureFlagItem {
    
    /// 기능 플래그의 타입
    public let type: FeatureFlagType
    
    /// 기능 플래그가 활성화되어 있는지를 나타내는 Bool 값
    public let isEnabled: Bool
    
    /// 새로운 `FeatureFlagItem`을 생성하는 초기화 메서드입니다.
    ///
    /// - Parameters:
    ///   - type: 기능 플래그의 타입
    ///   - isEnabled: 기능 플래그가 활성화되어 있는지를 나타내는 Bool 값
    public init(
        type: FeatureFlagType,
        isEnabled: Bool
    ) {
        self.type = type
        self.isEnabled = isEnabled
    }
}
