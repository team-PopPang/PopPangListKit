//
//  SectionsBuilder.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Foundation

/// 여러 Section을 선언형 DSL로 작성해서 [Section] 배열로 만들어주는 resultBuilder
///
/// 예:
/// ```swift
/// SectionsBuilder {
///   Section(...)
///   Section(...)
/// }
/// → [Section]
/// ```
@resultBuilder
public enum SectionsBuilder {
    
    /// Section을 여러 개 직접 나열할 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// SectionsBuilder.build {
    ///     Section(id: "banner", cells: bannerCells)
    ///     Section(id: "popular", cells: popularCells)
    /// }
    /// ```
    ///
    /// 결과:
    /// ```swift
    /// [Section("banner"), Section("popular")]
    /// ```
    public static func buildBlock(_ components: Section...) -> [Section] {
        components
    }
    
    /// [Section] 배열들을 여러 개 나열할 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// let mainSections: [Section] = [...]
    /// let footerSections: [Section] = [...]
    ///
    /// SectionsBuilder.build {
    ///     mainSections
    ///     footerSections
    /// }
    /// ```
    ///
    /// 결과:
    /// ```swift
    /// mainSections + footerSections
    /// ```
    public static func buildBlock(_ components: [Section]...) -> [Section] {
        components.flatMap { $0 }
    }
    
    /// 이미 [Section] 하나만 들어온 경우 그대로 반환
    ///
    /// 사용 예:
    /// ```swift
    /// SectionsBuilder.build {
    ///     makeSections()
    /// }
    /// ```
    public static func buildBlock(_ components: [Section]) -> [Section] {
        components
    }
    
    /// if 문만 있고 else가 없을 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// SectionsBuilder.build {
    ///     if showBanner {
    ///         Section(id: "banner", cells: bannerCells)
    ///     }
    /// }
    /// ```
    ///
    /// showBanner == false 이면 빈 배열 반환
    public static func buildOptional(_ component: [Section]?) -> [Section] {
        component ?? []
    }
    
    /// if-else의 if 영역이 [Section]일 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// if isLogin {
    ///     loginSections
    /// } else {
    ///     guestSections
    /// }
    /// ```
    public static func buildEither(first component: [Section]) -> [Section] {
        component
    }
    
    /// if-else의 else 영역이 [Section]일 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// if isLogin {
    ///     loginSections
    /// } else {
    ///     guestSections
    /// }
    /// ```
    public static func buildEither(second component: [Section]) -> [Section] {
        component
    }
    
    /// Section 하나 또는 여러 개를 표현식으로 받음
    ///
    /// 사용 예:
    /// ```swift
    /// Section(id: "banner", cells: bannerCells)
    /// Section(id: "popular", cells: popularCells)
    /// ```
    ///
    /// 각각 [Section]으로 변환됨
    public static func buildExpression(_ expression: Section...) -> [Section] {
        expression
    }
    
    /// [Section] 배열 표현식을 받음
    ///
    /// 사용 예:
    /// ```swift
    /// makeMainSections()
    /// makeFooterSections()
    /// ```
    ///
    /// 여러 배열을 하나로 합침
    public static func buildExpression(_ expression: [Section]...) -> [Section] {
        expression.flatMap { $0 }
    }
    
    /// for 문에서 만들어진 여러 [Section]을 하나로 합침
    ///
    /// 사용 예:
    /// ```swift
    /// for category in categories {
    ///     Section(id: category.id, cells: category.cells)
    /// }
    /// ```
    ///
    /// 결과:
    /// ```swift
    /// categories.map { Section(...) }
    /// ```
    public static func buildArray(_ components: [[Section]]) -> [Section] {
        components.flatMap { $0 }
    }
}
