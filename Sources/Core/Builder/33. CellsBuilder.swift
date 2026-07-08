//
//  CellsBuilder.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import Foundation

/// 여러 Cell을 선언형 DSL로 작성해서 [Cell] 배열로 만들어주는 resultBuilder
///
/// 예:
/// ```swift
/// CellsBuilder {
///   Cell(...)
///   Cell(...)
/// }
/// → [Cell]
/// ```
@resultBuilder
public enum CellsBuilder {
    
    /// Cell을 여러 개 직접 나열할 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// CellsBuilder.build {
    ///     Cell(id: "a", component: AComponent())
    ///     Cell(id: "b", component: BComponent())
    /// }
    /// ```
    ///
    /// 결과:
    /// ```swift
    /// [Cell("a"), Cell("b")]
    /// ```
    public static func buildBlock(_ components: Cell...) -> [Cell] {
        components
    }
    
    /// [Cell] 배열들을 여러 개 나열할 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// let headerCells: [Cell] = [...]
    /// let bodyCells: [Cell] = [...]
    ///
    /// CellsBuilder.build {
    ///     headerCells
    ///     bodyCells
    /// }
    /// ```
    ///
    /// 결과:
    /// ```swift
    /// headerCells + bodyCells
    /// ```
    public static func buildBlock(_ components: [Cell]...) -> [Cell] {
        components.flatMap { $0 }
    }
    
    /// 이미 [Cell] 하나만 들어온 경우 그대로 반환
    ///
    /// 사용 예:
    /// ```swift
    /// CellsBuilder.build {
    ///     makeCells()
    /// }
    /// ```
    public static func buildBlock(_ components: [Cell]) -> [Cell] {
        components
    }
    
    /// if 문만 있고 else가 없을 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// CellsBuilder.build {
    ///     if isLogin {
    ///         Cell(id: "profile", component: ProfileComponent())
    ///     }
    /// }
    /// ```
    ///
    /// isLogin == false 이면 빈 배열 반환
    public static func buildOptional(_ component: [Cell]?) -> [Cell] {
        component ?? []
    }
    
    /// if-else의 if 영역이 [Cell]일 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// if isLogin {
    ///     loginCells
    /// } else {
    ///     guestCells
    /// }
    /// ```
    public static func buildEither(first component: [Cell]) -> [Cell] {
        component
    }
    
    /// if-else의 if 영역에서 Cell을 직접 나열할 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// if isLogin {
    ///     Cell(id: "profile", component: ProfileComponent())
    /// } else {
    ///     Cell(id: "login", component: LoginComponent())
    /// }
    /// ```
    public static func buildEither(first component: Cell...) -> [Cell] {
        component
    }
    
    /// if-else의 else 영역이 클로저 형태일 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// if isLogin {
    ///     loginCells
    /// } else {
    ///     { guestCells }
    /// }
    /// ```
    ///
    /// 일반적인 DSL에서는 잘 안 쓰는 형태
    public static func buildEither(second component: () -> [Cell]) -> [Cell] {
        component()
    }
    
    /// if-else의 else 영역이 [Cell]일 때 호출됨
    ///
    /// 사용 예:
    /// ```swift
    /// if isLogin {
    ///     loginCells
    /// } else {
    ///     guestCells
    /// }
    /// ```
    public static func buildEither(second component: [Cell]) -> [Cell] {
        component
    }
    
    /// Cell 하나 또는 여러 개를 표현식으로 받음
    ///
    /// 사용 예:
    /// ```swift
    /// Cell(id: "a", component: AComponent())
    /// Cell(id: "b", component: BComponent())
    /// ```
    ///
    /// 각각 [Cell]로 변환됨
    public static func buildExpression(_ expression: Cell...) -> [Cell] {
        expression
    }
    
    /// [Cell] 배열 표현식을 받음
    ///
    /// 사용 예:
    /// ```swift
    /// makeHeaderCells()
    /// makeBodyCells()
    /// ```
    ///
    /// 여러 배열을 하나로 합침
    public static func buildExpression(_ expression: [Cell]...) -> [Cell] {
        expression.flatMap { $0 }
    }
    
    /// for 문에서 만들어진 여러 [Cell]을 하나로 합침
    ///
    /// 사용 예:
    /// ```swift
    /// for popup in popups {
    ///     Cell(id: popup.id, component: PopupComponent(popup))
    /// }
    /// ```
    ///
    /// 결과:
    /// ```swift
    /// popups.map { Cell(...) }
    /// ```
    public static func buildArray(_ components: [[Cell]]) -> [Cell] {
        components.flatMap { $0 }
    }
}
