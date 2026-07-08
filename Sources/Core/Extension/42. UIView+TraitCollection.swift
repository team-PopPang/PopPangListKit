//
//  UIView+TraitCollection.swift
//  PopPangListKit
//
//  Created by 김동현 on 4/24/26.
//

import UIKit

extension UIView {
    
    /// 콘텐츠 사이즈를 다시 계산해야 하는지 여부를 판단합니다.
    ///
    /// - Parameters:
    ///   - previousTraitCollection: 이전 traitCollection
    /// - Returns: 사이즈를 다시 계산해야 하면 true, 아니면 false
    func shouldInvalidateContentSize(
        previousTraitCollection: UITraitCollection?
    ) -> Bool {
        
        /// Dynamic Type(폰트 크기)가 변경된 경우
        if traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory {
            return true
        }
        
        /// 텍스트 가독성(weight)이 변경된 경우
        if traitCollection.legibilityWeight != previousTraitCollection?.legibilityWeight {
            return true
        }
        
        /// 화면 사이즈 클래스 (가로/세로)가 변경된 경우
        if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass ||
            traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            return true
        }
        
        /// 변경 사항이 없으면 사이즈 재계산 불필요
        return false
    }
}
