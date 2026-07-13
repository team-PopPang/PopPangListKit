//
//  AnyEquatableTests.swift
//  PopPangListKitDemo
//
//  Created by 김동현 on 7/7/26.
//

import Foundation
import Testing
@testable import PopPangListKit

@Suite("Any Equatable Tests")
struct AnyEquatableTests {

    @Test("같은 타입, 같은 값이면 true")
    func sameTypeSameValue() {
        let lhs: any Equatable = 10
        let rhs: any Equatable = 10

        #expect(lhs.isEqual(rhs))
    }

    @Test("같은 타입, 다른 값이면 false")
    func sameTypeDifferentValue() {
        let lhs: any Equatable = 10
        let rhs: any Equatable = 20

        #expect(!lhs.isEqual(rhs))
    }

    @Test("다른 타입이면 false")
    func differentType() {
        let lhs: any Equatable = 10
        let rhs: any Equatable = "10"

        #expect(!lhs.isEqual(rhs))
    }

    @Test("String 같은 타입 비교")
    func stringSameValue() {
        let lhs: any Equatable = "PopPang"
        let rhs: any Equatable = "PopPang"

        #expect(lhs.isEqual(rhs))
    }

    @Test("브릿징 타입 Int와 NSNumber 비교")
    func intAndNSNumberBridging() {
        let lhs: any Equatable = 10
        let rhs: any Equatable = NSNumber(value: 10)

        #expect(lhs.isEqual(rhs))
        #expect(rhs.isEqual(lhs))
    }

    @Test("브릿징 타입 Int와 NSNumber 값이 다르면 false")
    func intAndNSNumberDifferentValue() {
        let lhs: any Equatable = 10
        let rhs: any Equatable = NSNumber(value: 20)

        #expect(!lhs.isEqual(rhs))
        #expect(!rhs.isEqual(lhs))
    }
}
