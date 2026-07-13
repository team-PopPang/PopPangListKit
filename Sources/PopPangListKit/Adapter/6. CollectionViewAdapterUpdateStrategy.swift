//
//  CollectionViewAdapterUpdateStrategy.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/7/26.
//

import Foundation

public enum CollectionViewAdapterUpdateStrategy {
    
    /// 새로운 데이터를 기반으로 `performBatchUpdates(…)`를 호출하여
    /// 애니메이션이 포함된 배치 업데이트를 수행합니다.
    case animatedBatchUpdates

    /// 새로운 데이터를 기반으로 `performBatchUpdates(…)`를 호출하되,
    /// `UIView.performWithoutAnimation(…)`으로 감싸서
    /// 애니메이션 없이 배치 업데이트를 수행합니다.
    ///
    /// `reloadData`보다 성능이 좋습니다.
    /// (보이는 모든 셀을 다시 생성하고 구성하지 않기 때문입니다.)
    case nonanimatedBatchUpdates

    /// `reloadData()`를 호출하여 애니메이션 없이 업데이트를 수행합니다.
    /// 이 방식은 보이는 모든 셀을 다시 생성하고 재구성합니다.
    ///
    /// UIKit 엔지니어들은 업데이트 시 `reloadData`를 사용할 필요가 없으며,
    /// 대신 모든 콘텐츠 업데이트는 batch updates를 사용하는 것을 권장합니다.
    case reloadData
}
