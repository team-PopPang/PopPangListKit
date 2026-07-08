//
//  CollectionViewAdapterConfiguration.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import UIKit

public struct CollectionViewAdapterConfiguration {
    public let refreshControl: RefreshControl
    public let refreshControlAppearance: RefreshControl.Appearance?
    
    /// changeSet 횟수가 batchUpdateInterruptCount를 초과하면,
    /// UICollectionView는 애니메이션 업데이트 대신 reloadData를 사용하여 작동합니다.
    ///
    /// The default value is 100.
    public let batchUpdateInterruptCount: Int
    
    /// true로 설정하면 항목을 업데이트할 때 reloadItems 대신 UICollectionView의 reconfigureItems API를 사용합니다.
    /// 기존 셀을 새로 생성하는 대신 업데이트하여 성능을 향상시킵니다.
    public let enablesReconfigureItems: Bool
    
    /// `UICollectionViewAdapter`의 새 인스턴스를 초기화합니다.
    ///
    /// - Parameters:
    ///   - refreshControl: RefreshControl of the CollectionView
    ///   - batchUpdateInterruptCount: 애니메이션 업데이트가 허용되는 최대 changeSet 횟수
    ///   - enablesReconfigureItems: 항목 업데이트에 reconfigureItems API를 사용할지 여부
    public init(
        refreshControl: RefreshControl = .disabled(),
        refreshControlAppearance: RefreshControl.Appearance? = nil,
        batchUpdateInterruptCount: Int = 100,
        enablesReconfigureItems: Bool = false
    ) {
        self.refreshControl = refreshControl
        self.refreshControlAppearance = refreshControlAppearance
        self.batchUpdateInterruptCount = batchUpdateInterruptCount
        self.enablesReconfigureItems = enablesReconfigureItems
    }
}

extension CollectionViewAdapterConfiguration {
    
    /// RefreshControl에 대한 정보를 나타냅니다.
    public struct RefreshControl {
        /// RefreshControl이 적용되었는지 여부를 나타냅니다.
        public let isEnabled: Bool
        
        // RefreshControl의 색상입니다.
        public let tintColor: UIColor
        
        // RefreshControl에 표시할 텍스트입니다.
        public let text: String?
        
        // RefreshControl에 표시할 텍스트 색상입니다.
        public let textColor: UIColor?
        
        /// 이 함수를 사용하여 RefreshControl을 활성화하고 색상을 설정합니다.
        public static func enabled(
            tintColor: UIColor,
            text: String? = nil,
            textColor: UIColor? = nil
        ) -> RefreshControl {
            .init(
                isEnabled: true,
                tintColor: tintColor,
                text: text,
                textColor: textColor
            )
        }
        
        /// 이 함수를 사용하여 RefreshControl을 비활성화합니다.
        public static func disabled() -> RefreshControl {
            .init(
                isEnabled: false,
                tintColor: .clear,
                text: nil,
                textColor: nil
            )
        }
    }
}

extension CollectionViewAdapterConfiguration.RefreshControl {
    
    public struct Appearance {
        public let indicator: Indicator
        
        public init(indicator: Indicator) {
            self.indicator = indicator
        }
    }
}

extension CollectionViewAdapterConfiguration.RefreshControl.Appearance {
    
    public struct Indicator {
        public let image: UIImage
        public let size: CGFloat?
        public let tintColor: UIColor?
        public let spinDuration: TimeInterval?
        
        public static func image(_ image: UIImage) -> Self {
            .init(
                image: image,
                size: nil,
                tintColor: nil,
                spinDuration: nil
            )
        }
        
        public func size(_ value: CGFloat) -> Self {
            .init(
                image: image,
                size: value,
                tintColor: tintColor,
                spinDuration: spinDuration
            )
        }
        
        public func tintColor(_ color: UIColor) -> Self {
            .init(
                image: image,
                size: size,
                tintColor: color,
                spinDuration: spinDuration
            )
        }
        
        public func spin(duration: TimeInterval = 0.8) -> Self {
            .init(
                image: image,
                size: size,
                tintColor: tintColor,
                spinDuration: duration
            )
        }
    }
}
