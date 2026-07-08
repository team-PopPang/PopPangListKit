//
//  SupplementaryView.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import UIKit

public struct SupplementaryView: Equatable {
    
    /// 보조 뷰의 종류(header, footer 등)
    public let kind: String
    
    /// 보조 뷰를 구성하는 타입 소거된 Component
    public let component: AnyComponent
    
    /// 보조 뷰의 정렬 위치
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
