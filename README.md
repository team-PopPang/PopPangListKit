# PopPangListKit

> **SwiftUI처럼 선언하고, UICollectionView처럼 통제합니다.**

PopPangListKit은 복잡한 목록에서 UIKit의 통제력과 SwiftUI의 생산성을 함께 얻기 위해 만든 List DSL입니다.

개발자는 `List`, `Section`, `Cell`을 선언합니다. Core는 `UICollectionView`, Compositional Layout, DifferenceKit으로 diff, cell reuse, layout과 scroll event를 처리합니다. 기존 UIKit `Component`와 SwiftUI `View`는 같은 Section, 같은 데이터 snapshot, 같은 업데이트 경로를 공유합니다.

## 왜 만들었나요?

SwiftUI `List`는 표준 목록을 빠르게 구현할 때 적합합니다. 데이터 규모가 크지 않고 디자인 자유도가 중요하다면 `ScrollView + LazyVStack`도 좋은 선택입니다.

목록이 커지고 interaction이 복잡해지면 다른 문제가 생깁니다. Section별 세로·가로·그리드 배치, 동적 높이, 원격 이미지 prefetch, pagination, scroll lifecycle과 실시간 데이터 반영을 함께 다루려면 데이터와 셀이 갱신되는 과정을 예측할 수 있어야 합니다.

UIKit에서는 데이터 상태를 명시적으로 적용하고 diff 결과를 batch update로 반영할 수 있습니다. cell reuse와 delegate lifecycle도 드러나므로 병목을 측정하고 업데이트 전략을 조정할 수 있습니다. 반면 화면마다 data source와 delegate를 다시 구현하면 코드가 늘고 동작이 분산됩니다.

PopPangListKit은 목록의 뼈대를 `UICollectionView`로 유지하면서 SwiftUI와 유사한 선언형 작성 경험을 제공합니다.

| 선택 | 적합한 화면 | 감수할 점 |
|---|---|---|
| SwiftUI `List` | swipe, edit, selection 같은 플랫폼 기본 목록 기능이 중요한 화면 | 여백, 배경, 구분선 같은 기본 규칙을 커스텀 디자인에서 우회해야 할 수 있음 |
| `ScrollView + LazyVStack` | 카드형 피드처럼 디자인 자유도가 중요한 화면 | swipe, edit, selection, separator를 직접 구현해야 함 |
| `UICollectionView` | 데이터 갱신, cell reuse, prefetch와 scroll lifecycle을 예측하고 튜닝해야 하는 화면 | data source, delegate, diff와 이벤트 연결 코드가 늘어남 |
| PopPangListKit | 선언형 문법과 UICollectionView의 통제력이 모두 필요한 화면 | UIKit Core 위에서 UIKit Component와 SwiftUI View를 함께 사용 |

PopPangListKit은 SwiftUI `List`의 모든 기능을 복제하지 않습니다. SwiftUI의 선언형 작성 경험과 UICollectionView의 명시적인 렌더링 경로를 하나의 DSL로 결합합니다.

## 목차

- [지원 사양](#지원-사양)
- [기능 지원표](#기능-지원표)
- [설치](#설치)
- [설계 기준](#설계-기준)
- [빠른 시작](#빠른-시작)
- [Core 구조](#core-구조)
- [DifferenceKit을 선택한 이유](#differencekit을-선택한-이유)
- [핵심 개념](#핵심-개념)
- [레이아웃과 이벤트](#레이아웃과-이벤트)
- [SwiftUI 업데이트 전략](#swiftui-업데이트-전략)
- [트러블슈팅](#트러블슈팅)
- [Demo 앱](#demo-앱)
- [디렉터리 구조](#디렉터리-구조)

## 지원 사양

| 항목 | 사양 |
|---|---|
| 최소 지원 버전 | iOS 13.0+ |
| Demo app | iOS 17.0+ |
| UI 프레임워크 | UIKit, SwiftUI |
| 렌더링 엔진 | `UICollectionView` + `UICollectionViewCompositionalLayout` |
| 데이터 갱신 | DifferenceKit 기반 snapshot diff와 batch update |
| SwiftUI 연결 | `UIViewControllerRepresentable` + `UIHostingController` |
| 레이아웃 | Vertical, Horizontal, Vertical Grid, Custom Section |
| 배포 방식 | Swift Package Manager |

Framework와 Tests는 iOS 13부터 지원합니다. Demo app은 최신 SwiftUI API를 활용한 예제를 제공하기 위해 iOS 17을 유지합니다.

## 설치

Xcode의 **File > Add Package Dependencies...**에서 아래 URL을 추가한 뒤, `1.0.0`부터의 다음 major 버전을 허용하는 규칙을 선택합니다.

```text
https://github.com/team-PopPang/PopPangListKit.git
```

`Package.swift`를 사용하는 프로젝트에서는 다음처럼 연결합니다.

```swift
dependencies: [
    .package(
        url: "https://github.com/team-PopPang/PopPangListKit.git",
        from: "1.0.0"
    ),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "PopPangListKit", package: "PopPangListKit"),
        ]
    ),
]
```

## 설계 기준

| 기준 | PopPangListKit의 선택 |
|---|---|
| 선언 방식 | 화면은 `List -> Section -> Cell` 데이터로 표현합니다. |
| 렌더링 경로 | `UICollectionView`가 cell reuse, layout, lifecycle을 담당합니다. |
| 데이터 갱신 | 새 `List` snapshot을 명시적으로 `apply`하고 DifferenceKit으로 변경을 계산합니다. |
| UIKit과 SwiftUI | 기존 UIKit `Component`와 SwiftUI `View`를 같은 Section에서 함께 사용합니다. |
| 레이아웃 | Section별 Compositional Layout을 구성해 세로, 가로, 그리드와 custom section을 섞습니다. |
| 이벤트와 성능 | scroll lifecycle과 prefetch를 modifier/plugin 경계로 연결해 화면 코드에 delegate를 흩뜨리지 않습니다. |

## 빠른 시작

### SwiftUI 반복 Cell

여러 데이터를 같은 SwiftUI Cell로 표현할 때는 `For`를 사용합니다. 각 Element는 `Equatable`이어야 하며, 내부에서 기존 `Cell(id:item:)`으로 변환됩니다. 따라서 Element가 변경되면 DifferenceKit이 같은 ID의 콘텐츠 변경을 감지합니다.

```swift
import PopPangListKit
import SwiftUI
import UIKit

struct PopupListView: View {
    @State private var popups: [Popup] = []

    var body: some View {
        PopPangList {
            Section(id: "popups") {
                For(popups, id: \.id) { popup in
                    PopupRow(popup: popup)
                }
                .didSelect { popup in
                    print("selected: \(popup.id)")
                }
            }
            .withSectionLayout(
                VerticalLayout(spacing: 8)
                    .insets(
                        NSDirectionalEdgeInsets(
                            top: 16,
                            leading: 20,
                            bottom: 16,
                            trailing: 20
                        )
                    )
            )
        }
    }
}
```

`layoutMode`는 SwiftUI View의 디자인 modifier가 아니라 Cell의 컬렉션 배치 규칙입니다. `For`의 modifier로 선언하면 생성되는 모든 Cell에 적용됩니다.

```swift
For(popups, id: \.id) { popup in
    PopupCard(popup: popup)
        .frame(width: 194, height: 271)
}
.layoutMode(
    .fitContent(
        estimatedSize: .init(width: 194, height: 271)
    )
)
```

하나만 표시하거나 collection view의 `EventContext`가 필요할 때는 기존 `Cell(id:item:content:)`을 사용합니다.

### SwiftUI Binding Cell

`Toggle`, `TextField`, `Picker`처럼 양방향 상태가 필요한 Cell은 `Binding<Item>`을 전달합니다. 입력 View가 부모 상태를 직접 읽고 쓰므로 새로운 collection snapshot이 적용되기 전에도 UI와 상태가 일치합니다.

```swift
struct InteractiveListView: View {
    @State private var items: [Item] = []

    var body: some View {
        PopPangList {
            Section(id: "interactive") {
                for index in items.indices {
                    let item = $items[index]

                    Cell(id: item.wrappedValue.id, item: item) { item in
                        Toggle("활성화", isOn: item.isEnabled)

                        Button("+1") {
                            item.wrappedValue.count += 1
                        }
                    }
                }
            }
        }
    }
}
```

### SwiftUI Header와 Footer

SwiftUI 상태를 Header나 Footer에서 바로 사용한다면 `item` 없이 선언합니다. 새 List snapshot이 적용되면 캡처한 상태를 반영합니다.

```swift
Section(id: "popups") {
    // Cells
}
.withHeader {
    Text("\(popups.count)개의 팝업")
        .font(.headline)
}
.withFooter {
    Button("더 보기") {
        loadMore()
    }
}
```

`item:` overload는 특정 `Equatable` 값이 바뀔 때만 Header나 Footer를 갱신하고 싶을 때 사용합니다. `layoutMode`는 기본 `.flexibleHeight(estimatedHeight: 44)`로 충분하면 생략할 수 있습니다.

### UIKit Component

UIKit에서는 `Component`를 Cell에 직접 넣고 Core `List`를 Adapter에 적용합니다.

```swift
let layoutAdapter = CollectionViewLayoutAdapter()
let collectionView = UICollectionView(layoutAdapter: layoutAdapter)
let adapter = CollectionViewAdapter(
    configuration: .init(),
    collectionView: collectionView,
    layoutAdapter: layoutAdapter
)

let list = List {
    Section(id: "popups") {
        for popup in popups {
            Cell(
                id: popup.id,
                component: PopupComponent(item: popup)
            )
        }
    }
    .withSectionLayout(VerticalLayout(spacing: 8))
}

adapter.apply(list)
```

### UIKit과 SwiftUI 혼합

하나의 Section에 기존 UIKit Component와 SwiftUI View를 함께 넣을 수 있습니다.

```swift
PopPangList {
    Section(id: "main") {
        Cell(
            id: "banner",
            component: BannerComponent(item: banner)
        )

        For(popups, id: \.id) { popup in
            PopupRow(popup: popup)
        }
    }
}
```

### 홈 카드 레이아웃

카드 크기는 `For`의 `.layoutMode(_:)`에서 선언합니다. 이 값은 생성되는 각 `Cell`에 적용됩니다. 같은 `layoutMode`를 가진 카드에서 `.paging`, `.groupPaging`, `.groupPagingCentered`, `.continuousGroupLeadingBoundary`를 사용하면 `HorizontalLayout`이 카드 하나를 반복 group으로 구성합니다.

```swift
let headerTitle = "오픈 예정"

PopPangList {
    Section(id: "coming") {
        For(popups, id: \.id) { popup in
            PopupCard(popup: popup)
                .frame(width: 283, height: 138)
        }
        .layoutMode(
            .fitContent(
                estimatedSize: .init(width: 283, height: 138)
            )
        )
    }
    .withHeader(item: headerTitle) {
        Text(headerTitle)
            .font(.headline)
    }
    .withSectionLayout(
        HorizontalLayout(
            spacing: 15,
            scrollingBehavior: .groupPaging
        )
        .insets(.init(top: 0, leading: 20, bottom: 24, trailing: 20))
    )
}
```

가변 크기 cell을 섞는 일반 가로 목록은 `.continuous`를 사용합니다. `.none`은 가로 스크롤 없이 같은 가로 group을 배치합니다. 전체 조합 예제는 Demo 앱의 `example 4 - Home list`에서 확인할 수 있습니다.

## Core 구조

```text
List snapshot
└─ Section
   ├─ Header / Footer
   └─ Cell
      └─ AnyComponent
         ├─ UIKit Component
         └─ SwiftUIHostingComponent
                ↓
CollectionViewAdapter
├─ DifferenceKit diff
├─ UICollectionView batch update
└─ Compositional Layout
```

여기서 snapshot은 특정 시점의 `List`, `Section`, `Cell` 상태를 뜻합니다. `NSDiffableDataSourceSnapshot`이나 `UICollectionViewDiffableDataSource`를 사용한다는 의미는 아닙니다. PopPangListKit은 DifferenceKit으로 이전 Core `List`와 새로운 Core `List`를 비교합니다.

| 타입 | 역할 | 주로 사용하는 시점 |
|---|---|---|
| `Component` | UIKit View와 Item, 렌더링 규칙을 묶는 최소 단위 | 기존 UIKit 셀 UI를 연결할 때 |
| `AnyComponent` | 서로 다른 `Component`를 하나의 Cell 모델로 다루는 타입 소거 래퍼 | 목록 내부 저장과 diff 비교 시 |
| `Cell` | 컬렉션 뷰 아이템 모델 | 아이템 UI와 이벤트를 선언할 때 |
| `Section` | Cell, header, footer, layout을 묶는 모델 | 섹션별 화면 구조를 만들 때 |
| `List` | 화면 전체 snapshot과 리스트 이벤트 | 렌더링할 목록 상태를 구성할 때 |
| `CollectionViewAdapter` | `List`와 `UICollectionView`를 연결하는 어댑터 | UIKit 화면에 목록을 반영할 때 |
| `CollectionViewLayoutAdapter` | Section 데이터와 Compositional Layout을 연결 | `UICollectionViewCompositionalLayout`을 구성할 때 |
| `SwiftUIHostingComponent` | SwiftUI View를 기존 Component 경로에 연결 | UIKit과 SwiftUI 셀을 혼합할 때 |

## DifferenceKit을 선택한 이유

`reloadData()`는 애플리케이션에서 변경점을 계산하지 않고 UICollectionView에 전체 데이터를 다시 요청합니다. DifferenceKit은 Paul Heckel 알고리즘으로 삽입, 삭제, 이동과 갱신을 선형 시간 `O(n)`에 계산하고 결과를 `StagedChangeset`으로 제공합니다.

PopPangListKit은 계산된 변경을 batch update로 반영합니다. changeset 수가 설정한 임계값을 넘으면 복잡한 animation batch 대신 `reloadData()`를 사용합니다.

| 방식 | 변경 계산 | UI 반영 |
|---|---|---|
| `reloadData()` | 별도 diff 없음 | 전체 데이터 다시 요청 |
| `UICollectionViewDiffableDataSource` | UIKit 내부 diff, 복잡도는 공개 계약이 아님 | 시스템이 계산한 변경 반영 |
| PopPangListKit + DifferenceKit | Core snapshot을 Heckel `O(n)`으로 비교 | `StagedChangeset`의 변경 중심 batch update |

`O(n)`은 DifferenceKit의 diff 계산 복잡도입니다. UIKit의 layout과 rendering을 포함한 전체 업데이트 비용이 항상 `O(n)`이라는 뜻은 아닙니다. 자세한 알고리즘과 benchmark는 [DifferenceKit 공식 저장소](https://github.com/ra1028/DifferenceKit)에서 확인할 수 있습니다.

| 업데이트 방식 | API | 사용 시점 |
|---|---|---|
| Animated batch update | `.animatedBatchUpdates` | 일반적인 변경에 animation을 적용할 때 |
| Non-animated batch update | `.nonanimatedBatchUpdates` | 변경분만 반영하되 animation은 피할 때 |
| Full reload | `.reloadData` | 변경량이 많거나 안전한 전체 갱신이 필요할 때 |
| Latest update queue | `CollectionViewAdapter` 내부 큐 | 업데이트 중 새 상태가 오면 가장 최근 snapshot으로 이어갈 때 |

## 핵심 개념

### Component

`Component`는 PopPangListKit에서 화면에 표시할 데이터와 동작을 선언하는 가장 작은 단위입니다. Cell 데이터인 `Item`, 실제 UIKit View인 `Content`, 필요한 경우 View와 외부 상태를 연결하는 `Coordinator`를 하나의 계약으로 묶습니다.

개발자는 화면마다 `UICollectionViewCell`이나 `UICollectionReusableView`를 subclass로 만들 필요가 없습니다. 대신 Component를 작성하고 `Cell`, Header, Footer에 넣습니다. 목록은 공통 렌더링 Cell이 처리하고, Component는 화면에 필요한 View와 데이터 갱신 규칙만 정의합니다.

`Component`의 생성, 갱신, Coordinator 계약은 `UIViewRepresentable`과 비슷합니다. UIKit Component와 SwiftUI View는 같은 Section, snapshot, 업데이트 경로를 공유하므로 화면을 SwiftUI로 전환할 때 목록 구조와 갱신 로직을 다시 만들 필요가 없습니다.

```swift
public protocol Component {
    associatedtype Item: Equatable
    associatedtype Content: UIView
    associatedtype Coordinator = Void

    var item: Item { get }
    var reuseIdentifier: String { get }
    var layoutMode: ContentLayoutMode { get }

    func renderContent(coordinator: Coordinator) -> Content
    func render(in content: Content, coordinator: Coordinator)
    func layout(content: Content, in container: UIView)
    func makeCoordinator() -> Coordinator
}
```

`renderContent`는 재사용할 View를 처음 만들 때 호출하고, `render`는 같은 View에 새로운 Item을 반영할 때 호출합니다. View 생성과 상태 업데이트를 분리해 UICollectionView가 Cell을 재사용할 때마다 View hierarchy를 다시 만들지 않습니다.

#### UIKit Component 작성하기

`item`에는 화면에 표시할 값, `Content`에는 실제 UIKit View, `render`에는 Item을 View에 반영하는 코드를 둡니다.

```swift
import PopPangListKit
import UIKit

struct TitleComponent: Component {
    let item: String

    var layoutMode: ContentLayoutMode {
        .flexibleHeight(estimatedHeight: 44)
    }

    func renderContent(coordinator: Void) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }

    func render(in content: UILabel, coordinator: Void) {
        content.text = item
    }
}

let cell = Cell(
    id: "notice",
    component: TitleComponent(item: "새로운 팝업이 등록되었어요.")
)
```

Adapter는 처음 렌더링할 때 `makeCoordinator`, `renderContent`, `layout`, `render`를 차례로 호출합니다. 재사용한 Cell에는 새 View를 만들지 않고 `render`만 호출합니다. 기본 `layout`은 Content를 컨테이너의 네 변에 고정합니다. 다른 제약 조건이나 View 계층이 필요할 때만 `layout(content:in:)`을 구현합니다.

`item`은 `Equatable`이어야 합니다. 기본 `reuseIdentifier`는 Component 타입 이름입니다. 따라서 같은 Cell ID에서 `item`이나 Component 타입이 바뀌면 DifferenceKit이 콘텐츠 변경으로 판단해 Cell을 갱신합니다.

#### layoutMode와 실제 크기

`layoutMode`는 Compositional Layout이 처음 사용할 추정 크기와 Content가 늘어날 축을 정합니다. 표시 과정에서는 `sizeThatFits(_:)`로 실제 크기를 측정하고, Adapter가 그 값을 다음 layout 계산에 사용합니다.

| `ContentLayoutMode` | 너비 | 높이 | 적합한 UI |
|---|---|---|---|
| `.fitContainer` | 컨테이너에 맞춤 | 컨테이너에 맞춤 | 배경을 포함해 Cell 전체를 채우는 UI |
| `.flexibleHeight(estimatedHeight:)` | 컨테이너에 맞춤 | Content에 맞춤 | 일반적인 세로 목록 Cell |
| `.flexibleWidth(estimatedWidth:)` | Content에 맞춤 | 컨테이너에 맞춤 | 가로 목록의 높이가 정해진 카드 |
| `.fitContent(estimatedSize:)` | Content에 맞춤 | Content에 맞춤 | 너비와 높이가 모두 가변인 태그·카드 |

`sizeThatFits(_:)`를 직접 구현하면 동적 크기를 더 정확하게 계산할 수 있습니다. 추정값은 첫 layout을 위한 값이므로, 실제 Content 크기와 비슷하게 지정하는 편이 좋습니다.

### AnyComponent

Component는 associated type을 가지므로 서로 다른 Component를 하나의 배열에 바로 담을 수 없습니다. `AnyComponent`는 구체적인 `Item`, `Content`, `Coordinator` 타입을 지우고 Adapter가 모든 Component를 같은 인터페이스로 다루게 합니다.

```text
BannerComponent  ─┐
PopupComponent   ─┼─> AnyComponent ─> Cell ─> [Cell]
ProfileComponent ─┘
```

동등성 비교에는 Item과 `reuseIdentifier`가 사용됩니다. 같은 Cell ID 안에서 Item 또는 Component 타입이 바뀌면 DifferenceKit이 콘텐츠 변경으로 감지합니다.

### SwiftUIHostingComponent

`SwiftUIHostingComponent`는 SwiftUI View를 별도의 목록 엔진으로 처리하지 않습니다. SwiftUI View를 기존 Component 계약에 맞게 변환하는 Adapter입니다.

```text
SwiftUI View
   ↓
SwiftUIHostingComponent
   ↓
AnyComponent
   ↓
기존 Cell · DifferenceKit · CollectionViewAdapter
```

최초 렌더링에서 `HostingContentView`와 `UIHostingController`를 만들고, 데이터가 바뀌면 기존 hosting view에 새로운 `rootView`를 적용합니다.

## 레이아웃과 이벤트

Section마다 서로 다른 Compositional Layout을 적용할 수 있습니다.

- `VerticalLayout`
- `HorizontalLayout`
- `VerticalGridLayout`
- `CompositionalLayoutSectionFactory` 기반 Custom Section
- Header·Footer와 visible bounds pinning
- visible items invalidation handler

Cell과 List 이벤트도 DSL modifier로 연결합니다.

| 대상 | API 예시 | 설명 |
|---|---|---|
| `List` | `onRefresh`, `onReachEnd` | pull-to-refresh와 페이지네이션 이벤트를 연결합니다. |
| `List` | `didScroll`, `willBeginDragging`, `didEndDecelerating` | scroll, dragging, deceleration lifecycle을 받습니다. |
| `Section` | `withHeader`, `withFooter`, `withSectionLayout` | 보조 뷰와 Compositional Layout을 섹션에 붙입니다. |
| `Cell` | `didSelect`, `onHighlight`, `onUnhighlight` | 아이템 상호작용을 선언합니다. |
| `Cell` / `SupplementaryView` | `willDisplay`, `didEndDisplaying` | 표시와 재사용 lifecycle을 관찰합니다. |
| Prefetch plugin | `CollectionViewPrefetchingPlugin` | indexPath 기반 리소스 prefetch와 취소를 확장합니다. |

```swift
PopPangList(
    configuration: CollectionViewAdapterConfiguration(
        refreshControl: .enabled(
            tintColor: .systemGray,
            text: "새로고침 중..."
        )
    )
) {
    // Sections
}
.onRefresh { _ in
    reload()
}
.onReachEnd { _ in
    loadNextPage()
}
```

## SwiftUI 업데이트 전략

SwiftUI `PopPangList`는 iOS 15 이상에서 `reconfigureItems`를 기본 사용합니다. 현재 UICollectionViewCell을 유지하면서 콘텐츠를 갱신해 hosting view의 불필요한 재생성을 줄입니다. iOS 13~14에서는 자동으로 `reloadItems`를 사용합니다.

이 설정은 SwiftUI wrapper의 기본값입니다. UIKit에서 `CollectionViewAdapterConfiguration()`을 직접 만들 때는 기존 `reloadItems` 기본 동작을 유지합니다.

## 트러블슈팅

### Toggle이 상태 변경 직후 잠깐 되돌아가는 문제

초기 값 기반 Cell은 복사된 Item으로 Binding을 만들었습니다.

```swift
Binding(
    get: { item.isEnabled },
    set: onToggle
)
```

setter가 부모 상태를 변경해도 새로운 Core snapshot이 적용되기 전까지 getter는 이전 Item 값을 반환했습니다. Toggle이 새 값으로 이동했다가 잠깐 원래 값으로 돌아오는 것처럼 보이는 원인이었습니다.

입력 컨트롤을 위한 `Binding<Item>` Cell initializer를 추가해 해결했습니다.

```swift
let item = $items[index]

Cell(id: item.wrappedValue.id, item: item) { item in
    Toggle("상태", isOn: item.isEnabled)
}
```

입력 View가 부모 상태를 직접 읽고 쓰므로 collection snapshot 적용을 기다리지 않고 같은 값을 바라봅니다. `reconfigureItems`는 UIKit Cell 재생성을 줄이고, Binding DSL은 SwiftUI 입력 상태의 source of truth를 연결합니다. 두 기능은 서로 다른 문제를 해결합니다.

### 빠른 상태 변경에서 오래된 snapshot까지 적용되는 문제

`UIViewControllerRepresentable.updateUIViewController`에서 업데이트마다 독립적인 Task를 만들면 빠른 상태 변경 중 이전 snapshot도 `apply`를 요청할 수 있습니다.

```swift
Task { @MainActor in
    await Task.yield()
    viewController.apply(list)
}
```

Coordinator가 pending Task를 하나만 소유하도록 변경했습니다. 새로운 상태가 들어오면 아직 실행되지 않은 작업을 취소하고 최신 snapshot만 적용합니다.

```swift
final class Coordinator {
    private var pendingUpdate: Task<Void, Never>?

    func schedule(
        list: List,
        viewController: PopPangListViewController
    ) {
        pendingUpdate?.cancel()

        pendingUpdate = Task { @MainActor in
            await Task.yield()
            guard !Task.isCancelled else { return }
            viewController.apply(list)
        }
    }
}
```

`Task.yield()`는 제거하지 않습니다. SwiftUI가 View를 업데이트하는 도중 UICollectionView의 diff와 layout을 즉시 변경해 `Modifying state during view update` 경고가 발생하는 것을 피하기 위한 실행 경계입니다.

아직 시작하지 않은 apply는 pending Task 취소로 병합하고, 이미 시작된 UICollectionView 업데이트 중 들어온 최신 요청은 `CollectionViewAdapter.queuedUpdate`가 이어서 처리합니다.

## Demo 앱

[Demo](./Demo)는 독립적인 iOS 앱이며, [PopPangListKitDemo.xcodeproj](./Demo/PopPangListKitDemo.xcodeproj)를 열어 실행할 수 있습니다. Demo는 상위 `Package.swift`를 local package dependency로 연결합니다.

- UIKit Component 기반 Vertical Layout
- UIKit Component와 SwiftUI View 혼합
- 새로고침과 무한 스크롤
- Toggle과 Button을 포함한 Binding Cell
- UICollectionView Compositional Layout 비교 화면
- 기존 layoutMode로 구성한 Home list 화면

CLI 빌드는 다음 명령으로 검증할 수 있습니다.

```bash
xcodebuild \
  -project Demo/PopPangListKitDemo.xcodeproj \
  -scheme PopPangListKitDemo \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 디렉터리 구조

```text
PopPangListKit
├─ Package.swift
├─ Sources
│  ├─ Core
│  │  ├─ Adapter
│  │  ├─ Builder
│  │  ├─ CollectionReusable
│  │  ├─ Component
│  │  ├─ Event
│  │  ├─ Layout
│  │  ├─ Prefetching
│  │  └─ SwiftUISupport
│  └─ Support
├─ Demo
│  ├─ PopPangListKitDemo.xcodeproj
│  └─ Sources
├─ Tests
└─ .gitignore
```

PopPangListKit은 SwiftUI를 대체하지 않습니다. 단순하고 정적인 목록은 SwiftUI `List`나 `LazyVStack`으로 충분합니다. 복잡한 목록에서 업데이트 경로를 예측하고 튜닝해야 할 때 UICollectionView Core와 선언형 DSL을 함께 제공하는 것이 이 모듈의 역할입니다.

## 기능 지원표

두 화면은 같은 `List`, `Section`, `Cell` DSL과 Compositional Layout을 공유합니다. 표의 UIKit은 `CollectionViewAdapter`를 직접 연결하는 화면이고, SwiftUI는 `PopPangList`를 사용하는 화면입니다.

### UIKit 화면

| 구분 | API | 설명 |
|---|---|---|
| 목록 연결과 갱신 | `CollectionViewAdapter`, `adapter.apply(List)` | `UICollectionView`를 직접 만들고 원하는 시점에 새 List snapshot을 적용합니다. |
| UIKit Cell | `Cell(id:component:)` | `Component`로 `UIView` Cell을 렌더링합니다. |
| SwiftUI Cell | `Cell(id:item:content:)` | UIKit 목록 안에서도 SwiftUI View를 Cell로 렌더링합니다. |
| 반복 SwiftUI Cell | `For(data:id:content:).layoutMode(_:)` | `Equatable` 데이터를 반복해 SwiftUI Cell로 만들고 공통 크기 규칙·모델 기반 선택 이벤트를 연결합니다. |
| UIKit Header / Footer | `.withHeader(Component)`, `.withFooter(Component)` | `Component` 기반 supplementary view를 표시합니다. |
| SwiftUI Header / Footer | `.withHeader { ... }`, `.withFooter { ... }` | SwiftUI View를 supplementary view로 렌더링합니다. 캡처한 상태는 새 snapshot에서 갱신합니다. `item:` overload로 갱신 범위를 제한할 수 있습니다. |
| Cell 크기 | `ContentLayoutMode` | `.fitContainer`, `.flexibleHeight`, `.flexibleWidth`, `.fitContent`을 지원합니다. |
| Section Layout | `VerticalLayout`, `HorizontalLayout`, `VerticalGridLayout`, `DefaultCompositionalLayoutSectionFactory`, custom factory | 세로 목록, 가로 목록, 그리드, 기본 factory, custom Compositional Layout을 섞습니다. |
| 가로 스크롤 | `HorizontalLayout(scrollingBehavior:)` | `.none`, `.continuous`, `.continuousGroupLeadingBoundary`, `.paging`, `.groupPaging`, `.groupPagingCentered`을 지원합니다. |
| Header / Footer 고정 | `.headerPinToVisibleBounds`, `.footerPinToVisibleBounds` | 스크롤 중 supplementary view를 화면 경계에 고정합니다. |
| visible item 변경 | `.withVisibleItemsInvalidationHandler` | 스크롤 위치와 visible item 변화에 맞춰 layout item을 조정합니다. |
| Cell·Supplementary 이벤트 | `.didSelect`, `.onHighlight`, `.willDisplay`, `.willDisplayHeader` 등 | Cell 선택·highlight와 Cell·Header·Footer의 표시·제거 lifecycle을 받습니다. |
| List scroll lifecycle | `didScroll`, `willBeginDragging`, `willEndDragging` 등 | 전체 UIScrollView lifecycle과 scroll-to-top 여부를 제어합니다. |
| 새로고침과 페이지네이션 | `onRefresh`, `onReachEnd` | RefreshControl과 목록 끝 감지를 연결합니다. |
| 업데이트 전략 | `CollectionViewAdapterConfiguration` | batch update 임계값, refresh UI, `reconfigureItems` 사용 여부를 설정합니다. |
| 리소스 prefetch | `CollectionViewPrefetchingPlugin`, `RemoteImagePrefetchingPlugin` | UIKit Component의 이미지·리소스 prefetch와 취소를 확장합니다. |

### SwiftUI 화면

| 구분 | API | 설명 |
|---|---|---|
| 목록 연결과 갱신 | `PopPangList { ... }` | SwiftUI `body`가 다시 계산되면 새 List snapshot을 자동 적용합니다. |
| 값 기반 SwiftUI Cell | `Cell(id:item:content:)` | `Equatable` Item이 바뀌면 Cell 콘텐츠를 갱신합니다. |
| 반복 SwiftUI Cell | `For(data:id:content:).layoutMode(_:)` | `Equatable` 데이터를 반복해 Cell을 만들고, 공통 크기 규칙과 선택된 원본 모델을 설정합니다. |
| Binding SwiftUI Cell | `Cell(id:item: Binding, content:)` | `Toggle`, `TextField`처럼 양방향 상태가 필요한 Cell에 사용합니다. |
| item 없는 SwiftUI Cell | `Cell(id:content:)` | SwiftUI 상태를 직접 캡처해 렌더링합니다. 새 snapshot에서 콘텐츠를 갱신하며, 갱신 범위를 제한하려면 값 기반 Cell을 사용합니다. |
| UIKit Component Cell | `Cell(id:component:)` | SwiftUI 화면에서도 기존 UIKit Component를 함께 사용합니다. |
| UIKit Header / Footer | `.withHeader(Component)`, `.withFooter(Component)` | 기존 UIKit supplementary view를 그대로 사용합니다. |
| SwiftUI Header / Footer | `.withHeader { ... }`, `.withFooter { ... }` | SwiftUI View를 Section Header·Footer로 사용합니다. `item:` overload로 특정 값 기준 갱신도 선택할 수 있습니다. |
| Layout과 가로 스크롤 | UIKit 화면과 동일 | Vertical, Horizontal, Grid, 기본·custom layout과 6개 `scrollingBehavior`를 동일하게 사용합니다. |
| visible item 변경 | `.withVisibleItemsInvalidationHandler` | 스크롤 위치와 visible item 변화에 맞춰 layout item을 조정합니다. |
| Cell·Section 이벤트 | UIKit 화면과 동일 | Cell 상호작용, 표시 lifecycle, Header·Footer lifecycle을 modifier로 연결합니다. |
| List scroll lifecycle | UIKit 화면과 동일 | `onRefresh`, `onReachEnd`, `didScroll`, dragging·deceleration lifecycle, scroll-to-top 제어를 동일하게 사용합니다. |
| 업데이트 전략 | `PopPangList(configuration:)` | iOS 15 이상에서는 `reconfigureItems`를 기본으로 사용합니다. |
| 리소스 prefetch | `PopPangList(prefetchingPlugins:)` | UIKit Component가 제공하는 이미지·리소스 prefetch plugin을 연결합니다. |

SwiftUI `Cell`, Header, Footer도 UIKit 렌더링 경로를 사용합니다. 따라서 두 화면은 cell reuse, DifferenceKit diff, Compositional Layout을 동일하게 공유합니다.
