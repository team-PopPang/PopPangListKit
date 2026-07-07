//
//  Cell.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import Foundation
import DifferenceKit

public struct Cell: Identifiable {
    
    public let id: AnyHashable
    public let component: AnyComponent
    
    public init(id: some Hashable, component: some Component) {
        self.id = id
        self.component = AnyComponent(component: component)
    }
}

extension Cell: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Cell, rhs: Cell) -> Bool {
        lhs.id == rhs.id && lhs.component == rhs.component
    }
}

extension Cell: Differentiable {
    public var differenceIdentifier: AnyHashable {
        id
    }
    
    public func isContentEqual(to source: Cell) -> Bool {
        self == source
    }
}
