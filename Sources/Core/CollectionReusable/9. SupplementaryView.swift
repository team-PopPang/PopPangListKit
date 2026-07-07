//
//  SupplementaryView.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import UIKit

public struct SupplementaryView: Equatable {
    
    public let kind: String
    public let component: AnyComponent
    public let alignment: NSRectAlignment
    
    public init(
        kind: String,
        component: some Component,
        alignment: NSRectAlignment
    ) {
        self.kind = kind
        self.component = AnyComponent(component: component)
        self.alignment = alignment
    }
    
    public static func == (lhs: SupplementaryView, rhs: SupplementaryView) -> Bool {
        lhs.kind == rhs.kind &&
        lhs.component == rhs.component &&
        lhs.alignment == rhs.alignment
    }
}
