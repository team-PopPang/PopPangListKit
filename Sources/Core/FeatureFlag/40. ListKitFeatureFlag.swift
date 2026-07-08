//
//  File.swift
//  TurboListKit
//
//  Created by 김동현 on 4/24/26.
//

import Foundation

/// 기능 플래그 제공자를 주입하기 위한 인터페이스입니다.
public enum ListKitFeatureFlag {
    /// `ListKit`에서 사용하는 기능 플래그 제공자입니다.
    ///
    /// 기본값은 `DefaultFeatureFlagProvider`로 설정되어 있습니다.
    /// 커스텀 제공자로 교체하여 기능 플래그 동작을 변경할 수 있습니다.
    public static var provider: FeatureFlagProviding = DefaultFeatureFlagProvider()
}
