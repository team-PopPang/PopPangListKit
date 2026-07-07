//
//  Section.swift
//  PopPangListKitTests
//
//  Created by 김동현 on 7/7/26.
//

import Foundation

public struct Section: Identifiable {
    
    public let id: AnyHashable
    public var header: SupplementaryView?
    public var cells: [Cell]
    public var footer: SupplementaryView?
}
