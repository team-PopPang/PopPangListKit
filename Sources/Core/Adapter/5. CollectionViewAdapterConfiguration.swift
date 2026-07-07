//
//  CollectionViewAdapterConfiguration.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import UIKit

public struct CollectionViewAdapterConfiguration {
    
    /// changeSet 횟수가 batchUpdateInterruptCount를 초과하면,
    /// UICollectionView는 애니메이션 업데이트 대신 reloadData를 사용하여 작동합니다.
    ///
    /// The default value is 100.
    public let batchUpdateInterruptCount: Int
    
    /// true로 설정하면 항목을 업데이트할 때 reloadItems 대신 UICollectionView의 reconfigureItems API를 사용합니다.
    /// 기존 셀을 새로 생성하는 대신 업데이트하여 성능을 향상시킵니다.
    public let enablesReconfigureItems: Bool
    
    public init(
        batchUpdateInterruptCount: Int = 100,
        enablesReconfigureItems: Bool = false
    ) {
        self.batchUpdateInterruptCount = batchUpdateInterruptCount
        self.enablesReconfigureItems = enablesReconfigureItems
    }
}
