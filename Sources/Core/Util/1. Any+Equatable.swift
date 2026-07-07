//
//  Any+Equatable.swift
//  PopPangListKitDemo
//
//  Created by 김동현 on 7/7/26.
//

import Foundation

extension Equatable {

    /// 타입이 지워진(`any Equatable`) 값과 현재 값을 비교합니다.
    ///
    /// 기본적으로 현재 타입(`Self`)으로 캐스팅하여 비교하며,
    /// 실패하면 반대 방향으로도 한 번 더 비교를 시도합니다.
    ///
    /// 일부 브릿징 타입(예: `Int` ↔ `NSNumber`)은 한 방향 캐스팅만
    /// 가능한 경우가 있으므로 양쪽 방향 모두 확인합니다.
    ///
    /// ## Example
    /// ```swift
    /// let a: any Equatable = 10
    /// let b: any Equatable = 10
    ///
    /// a.isEqual(b) // true
    /// ```
    ///
    /// ## Bridging Example
    /// ```swift
    /// let a: any Equatable = 10                  // Int
    /// let b: any Equatable = NSNumber(value: 10)
    ///
    /// a.isEqual(b) // true
    /// ```
    ///
    /// - Parameter other: 비교할 대상
    /// - Returns: 두 값이 같으면 `true`, 아니면 `false`
    func isEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            // Int ↔ NSNumber 등의 브릿징 타입을 위해 반대 방향도 비교
            return other.isExactlyEqual(self)
        }
        return self == other
    }

    /// 같은 타입으로 캐스팅 가능한 경우에만 값을 비교합니다.
    ///
    /// `isEqual(_:)`에서 반대 방향 비교를 위해 사용하는 내부 헬퍼입니다.
    private func isExactlyEqual(_ other: any Equatable) -> Bool {
        guard let other = other as? Self else {
            return false
        }
        return self == other
    }
}
