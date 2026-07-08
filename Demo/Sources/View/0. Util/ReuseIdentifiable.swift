//
//  ReuseIdentifiable.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Foundation

protocol ReuseIdentifiable {}

extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}
