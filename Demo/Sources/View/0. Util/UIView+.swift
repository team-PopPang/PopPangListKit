//
//  UIView.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

extension UIView {
    /// 오토레이아웃이 계산한 최소 높이를 sizeThatFits 응답으로 변환해 셀 크기 계산에 사용한다.
    /// 라벨 텍스트 길이 + AutoLayout 제약을 보고, 이 셀이 필요한 높이를 계산해주는 장치
    /// 지정된 너비에서 라벨 줄 수, StackView 간격, 위/아래 여백을 반영해 필요한 높이를 계산
    func autoLayoutFittingSize(
        for size: CGSize,
        targetWidth: CGFloat? = nil,
        minimumHeight: CGFloat = 0
    ) -> CGSize {
        // 컬렉션뷰가 넘겨준 폭을 사용한다.
        // 폭이 0이면 오토레이아웃 계산이 꼬일 수 있어서 최소 1로 보정한다.
        let targetWidth = max(targetWidth ?? size.width, 1)

        // 가로는 targetWidth로 고정하고,
        // 세로는 "제약을 만족하는 최소 높이"를 계산하도록 요청하기 위한 기준값이다.
        let fittingSize = CGSize(
            width: targetWidth,
            height: UIView.layoutFittingCompressedSize.height
        )

        // 현재 뷰 내부의 오토레이아웃 제약(스택뷰, 라벨, 여백)을 기준으로
        // 필요한 실제 크기를 계산한다.
        // 가로는 반드시 targetWidth를 따르고,
        // 세로는 최소 필요한 높이를 구한다.
        let result = systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        // 폭은 고정한 값을 그대로 쓰고,
        // 높이는 계산 결과를 올림 처리해서 픽셀 경계 문제를 줄인다.
        return CGSize(
            width: targetWidth,
            height: max(ceil(result.height), minimumHeight)
        )
    }
}
