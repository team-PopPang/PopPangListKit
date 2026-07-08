//
//  VComponent.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit
import PopPangListKit

struct VerticalLayoutComponent: Component {
    typealias Item = VerticalLayoutItemView.Item
    
    var item: Item
    
    var layoutMode: ContentLayoutMode {
        .flexibleHeight(estimatedHeight: 54.0)
    }
    
    func renderContent(coordinator: Void) -> VerticalLayoutItemView {
        VerticalLayoutItemView()
    }
    
    func render(in content: VerticalLayoutItemView, coordinator: Void) {
        content.item = item
    }
}

final class VerticalLayoutItemView: UIView {
    struct Item: Equatable {
        let id: UUID
        var title: String?
        var subtitle: String?
        
        init(
            id: UUID = .init(),
            title: String? = nil,
            subtitle: String? = nil
        ) {
            self.id = id
            self.title = title
            self.subtitle = subtitle
        }
        
        static func random() -> Self {
            .init(
                title: String.randomWords(count: .random(in: 4...10), wordLength: 4...10),
                subtitle: Bool.random()
                    ? String.randomWords(count: .random(in: 4...10), wordLength: 4...10)
                    : nil
            )
        }
    }
    
    private enum Layout {
        static let verticalInset: CGFloat = 8
        static let spacing: CGFloat = 4
    }
    
    var item: Item = .init() {
        didSet {
            guard item != oldValue else { return }
            applyItem()
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var separatorHeightConstraint = separator.heightAnchor.constraint(
        equalToConstant: 1.0 / traitCollection.displayScale
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        separator.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)
        addSubview(separator)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Layout.verticalInset),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Layout.verticalInset),

            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorHeightConstraint,
        ])
    }
    
    private func applyItem() {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        titleLabel.isHidden = item.title == nil
        subtitleLabel.isHidden = item.subtitle == nil
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoLayoutFittingSize(for: size)
    }
}
