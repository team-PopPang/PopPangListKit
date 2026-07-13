//
//  ArrayChunksTests.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import Testing
@testable import PopPangListKit

@Suite("Array Chunks Tests")
struct ArrayChunksTests {

    @Test("배열을 지정한 개수만큼 나눈다")
    func chunks() {
        let numbers = [1, 2, 3, 4, 5, 6, 7]

        let result = numbers.chunks(ofCount: 3)

        #expect(result == [
            [1, 2, 3],
            [4, 5, 6],
            [7]
        ])
    }

    @Test("배열 크기가 count로 나누어 떨어지는 경우")
    func evenChunks() {
        let numbers = [1, 2, 3, 4]

        let result = numbers.chunks(ofCount: 2)

        #expect(result == [
            [1, 2],
            [3, 4]
        ])
    }

    @Test("count가 배열보다 큰 경우")
    func countGreaterThanArrayCount() {
        let numbers = [1, 2, 3]

        let result = numbers.chunks(ofCount: 10)

        #expect(result == [
            [1, 2, 3]
        ])
    }

    @Test("빈 배열은 빈 결과를 반환한다")
    func emptyArray() {
        let numbers: [Int] = []

        let result = numbers.chunks(ofCount: 3)

        #expect(result.isEmpty)
    }

    @Test("count가 1이면 모든 요소가 개별 chunk가 된다")
    func chunkSizeOne() {
        let numbers = [1, 2, 3]

        let result = numbers.chunks(ofCount: 1)

        #expect(result == [
            [1],
            [2],
            [3]
        ])
    }

    @Test("문자열 배열도 올바르게 동작한다")
    func stringArray() {
        let strings = ["A", "B", "C", "D"]

        let result = strings.chunks(ofCount: 2)

        #expect(result == [
            ["A", "B"],
            ["C", "D"]
        ])
    }
}
