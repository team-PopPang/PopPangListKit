//
//  Collection+SafeIndex.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
