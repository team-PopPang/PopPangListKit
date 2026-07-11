# PopPangListKit

> **SwiftUI처럼 선언하고, UICollectionView처럼 통제합니다.**

PopPangListKit은 복잡한 목록에서 UIKit의 통제력과 SwiftUI의 생산성을 함께 얻기 위해 만든 List DSL입니다.

개발자는 `List`, `Section`, `Cell`을 선언합니다. Core는 `UICollectionView`, Compositional Layout, DifferenceKit으로 diff, cell reuse, layout과 scroll event를 처리합니다. 기존 UIKit `Component`와 SwiftUI `View`는 같은 Section, 같은 데이터 snapshot, 같은 업데이트 경로를 공유합니다.

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

Framework와 Tests는 iOS 13부터 지원합니다. Demo app은 최신 SwiftUI API를 활용한 예제를 제공하기 위해 iOS 17을 유지합니다.

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

## 빠른 시작

### SwiftUI 값 기반 Cell

표시 중심의 Cell은 `Equatable` Item을 값으로 전달합니다. Item이 변경되면 DifferenceKit이 같은 ID의 콘텐츠 변경을 감지합니다.

```swift
import PopPangListKit
import SwiftUI
import UIKit

struct PopupListView: View {
    @State private var popups: [Popup] = []

    var body: some View {
        PopPangList {
            Section(id: "popups") {
                for popup in popups {
                    Cell(id: popup.id, item: popup) { popup in
                        PopupRow(popup: popup)
                    }
                    .didSelect { _ in
                        print("selected: \(popup.id)")
                    }
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

        for popup in popups {
            Cell(id: popup.id, item: popup) { popup in
                PopupRow(popup: popup)
            }
        }
    }
}
```

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

## DifferenceKit을 선택한 이유

`reloadData()`는 애플리케이션에서 변경점을 계산하지 않고 UICollectionView에 전체 데이터를 다시 요청합니다. DifferenceKit은 Paul Heckel 알고리즘으로 삽입, 삭제, 이동과 갱신을 선형 시간 `O(n)`에 계산하고 결과를 `StagedChangeset`으로 제공합니다.

PopPangListKit은 계산된 변경을 batch update로 반영합니다. changeset 수가 설정한 임계값을 넘으면 복잡한 animation batch 대신 `reloadData()`를 사용합니다.

| 방식 | 변경 계산 | UI 반영 |
|---|---|---|
| `reloadData()` | 별도 diff 없음 | 전체 데이터 다시 요청 |
| `UICollectionViewDiffableDataSource` | UIKit 내부 diff, 복잡도는 공개 계약이 아님 | 시스템이 계산한 변경 반영 |
| PopPangListKit + DifferenceKit | Core snapshot을 Heckel `O(n)`으로 비교 | `StagedChangeset`의 변경 중심 batch update |

`O(n)`은 DifferenceKit의 diff 계산 복잡도입니다. UIKit의 layout과 rendering을 포함한 전체 업데이트 비용이 항상 `O(n)`이라는 뜻은 아닙니다. 자세한 알고리즘과 benchmark는 [DifferenceKit 공식 저장소](https://github.com/ra1028/DifferenceKit)에서 확인할 수 있습니다.

## 핵심 개념

### Component

`Component`는 PopPangListKit의 최소 렌더링 단위입니다. Cell 데이터인 `Item`, 실제 UIKit View인 `Content`, 필요한 경우 View와 외부 상태를 연결하는 `Coordinator`를 하나의 계약으로 묶습니다.

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

- Cell selection, highlight, unhighlight
- will display, did end displaying
- pull to refresh
- reach end pagination
- scroll, dragging, deceleration
- indexPath 기반 prefetch와 취소 plugin

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

## Demo

[Demo](./Demo)는 다음 예제를 제공합니다.

- UIKit Component 기반 Vertical Layout
- UIKit Component와 SwiftUI View 혼합
- 새로고침과 무한 스크롤
- Toggle과 Button을 포함한 Binding Cell
- UICollectionView Compositional Layout 비교 화면

모듈 디렉터리에서 workspace를 생성하고 Demo scheme을 실행할 수 있습니다.

```bash
cd Projects/Shared/PopPangListKit
tuist generate
open PopPangListKit.xcworkspace
```

CLI 빌드는 다음 명령으로 검증합니다.

```bash
xcodebuild \
  -workspace PopPangListKit.xcworkspace \
  -scheme PopPangListKit-Workspace \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 디렉터리 구조

```text
PopPangListKit
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
├─ Tests
└─ Project.swift
```

PopPangListKit은 SwiftUI를 대체하지 않습니다. 단순하고 정적인 목록은 SwiftUI `List`나 `LazyVStack`으로 충분합니다. 복잡한 목록에서 업데이트 경로를 예측하고 튜닝해야 할 때 UICollectionView Core와 선언형 DSL을 함께 제공하는 것이 이 모듈의 역할입니다.
