//
//  ContentLayoutMode.swift
//  PopPangListKitDemo
//
//  Created by 김동현 on 7/7/26.
//

import Foundation
import CoreGraphics

/// `Component`의 콘텐츠를 `UICollectionView`에서 어떻게 배치할지 정의하는 enum입니다.
public enum ContentLayoutMode: Equatable {
    
    /// 콘텐츠 너비와 높이를 부모 컨테이너 크기에 맞게 조정합니다
    case fitContainer
    
    /// 콘텐츠의 너비는 부모 컨테이너에 맞추고
    /// 높이는 콘텐츠의 실제 크기에 맞춰 자동으로 조정합니다.
    ///
    /// 실제 높이를 계산하기 전까지 사용할 추정 높이를 제공합니다.
    ///
    /// - Parameter estimatedHeight: 콘텐츠의 예상 높이
    case flexibleHeight(estimatedHeight: CGFloat)
    
    /// 콘텐츠의 높이는 부모 컨테이너에서 맞추고,
    /// 너비는 콘텐츠의 실제 크기에 맞게 자동으로 조정합니다.
    ///
    /// 실제 너비를 계산하기 전까지 사용할 추정 너비를 제공합니다.
    ///
    /// - Parameter estimatedWidth: 콘텐츠의 예상 너비
    case flexibleWidth(estimatedWidth: CGFloat)
    
    /// 콘텐츠와 너비와 높이를 모두 콘텐츠 크기에 맞게 자동으로 조정합니다.
    ///
    /// 실제 사이즈를 계산하기 전까지 사용할 추정 크기를 제공합니다.
    ///
    /// - Parameter estimatedSize: 콘텐츠의 예상 크기
    case fitContent(estimatedSize: CGSize)
}
