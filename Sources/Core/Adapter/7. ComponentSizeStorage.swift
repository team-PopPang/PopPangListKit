//
//  ComponentSizeStorage.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import Foundation

public protocol ComponentSizeStorage {
    
    typealias SizeContext = (size: CGSize, item: AnyItem)
    
    // MARK: - get
    @MainActor
    func cellSize(for hash: AnyHashable) -> SizeContext?
    
    @MainActor
    func headerSize(for hash: AnyHashable) -> SizeContext?
    
    @MainActor
    func footerSize(for hash: AnyHashable) -> SizeContext?
    
    // MARK: - set
    @MainActor
    func setCellSize(_ size: SizeContext, for hash: AnyHashable)
    
    @MainActor
    func setHeaderSize(_ size: SizeContext, for hash: AnyHashable)
    
    @MainActor
    func setFooterSize(_ size: SizeContext, for hash: AnyHashable)
}

final class ComponentSizeStorageImpl: ComponentSizeStorage {
    
    private var cellSizeStore: [AnyHashable: SizeContext] = [:]
    private var headerSizeStore: [AnyHashable: SizeContext] = [:]
    private var footerSizeStore: [AnyHashable: SizeContext] = [:]
    
    @MainActor
    func cellSize(for hash: AnyHashable) -> SizeContext? {
        cellSizeStore[hash]
    }
    
    @MainActor
    func headerSize(for hash: AnyHashable) -> SizeContext? {
        headerSizeStore[hash]
    }
    
    @MainActor
    func footerSize(for hash: AnyHashable) -> SizeContext? {
        footerSizeStore[hash]
    }
    
    @MainActor
    func setCellSize(_ size: SizeContext, for hash: AnyHashable) {
        cellSizeStore[hash] = size
    }
    
    @MainActor
    func setHeaderSize(_ size: SizeContext, for hash: AnyHashable) {
        headerSizeStore[hash] = size
    }
    
    @MainActor
    func setFooterSize(_ size: SizeContext, for hash: AnyHashable) {
        footerSizeStore[hash] = size
    }
}
