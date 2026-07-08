//
//  String+.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Foundation

extension String {
    static func randomWords(count: Int, wordLength: ClosedRange<Int>) -> String {
        (0..<count)
            .map { _ in String.randomWord(length: .random(in: wordLength)) }
            .joined(separator: " ")
    }

    static func randomWord(length: Int) -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyz")
        return String((0..<length).map { _ in letters.randomElement() ?? "a" })
    }
}
