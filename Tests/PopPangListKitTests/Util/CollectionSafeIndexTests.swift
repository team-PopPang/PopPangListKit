//
//  CollectionSafeIndexTests.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import Testing
@testable import PopPangListKit

@Suite("Collection Safe Index Tests")
struct CollectionSafeIndexTests {

    @Test("Array의 유효한 index면 값을 반환한다")
    func arrayValidIndex() {
        let numbers = [10, 20, 30]

        #expect(numbers[safe: 1] == 20)
    }

    @Test("Array의 범위를 벗어난 index면 nil을 반환한다")
    func arrayInvalidIndex() {
        let numbers = [10, 20, 30]

        #expect(numbers[safe: 3] == nil)
    }

    @Test("빈 Array는 startIndex도 nil을 반환한다")
    func emptyArray() {
        let numbers: [Int] = []

        #expect(numbers[safe: numbers.startIndex] == nil)
    }

    @Test("String의 유효한 index면 Character를 반환한다")
    func stringValidIndex() {
        let text = "ABC"
        let index = text.index(text.startIndex, offsetBy: 1)

        #expect(text[safe: index] == "B")
    }

    @Test("String의 endIndex는 nil을 반환한다")
    func stringEndIndex() {
        let text = "ABC"

        #expect(text[safe: text.endIndex] == nil)
    }

    @Test("Dictionary의 유효한 index면 key-value pair를 반환한다")
    func dictionaryValidIndex() {
        let dictionary = ["A": 1, "B": 2]
        let index = dictionary.startIndex

        #expect(dictionary[safe: index] != nil)
    }

    @Test("Dictionary의 endIndex는 nil을 반환한다")
    func dictionaryEndIndex() {
        let dictionary = ["A": 1, "B": 2]

        #expect(dictionary[safe: dictionary.endIndex] == nil)
    }
}
