import UIKit
import PopPangListKit

struct SectionHeaderComponent: Component {
    struct Item: Equatable {
        let title: String
        let subtitle: String?
    }

    let item: Item

    var layoutMode: ContentLayoutMode {
        .flexibleHeight(estimatedHeight: 64)
    }

    func renderContent(coordinator: Void) -> SectionHeaderView {
        SectionHeaderView()
    }

    func render(in content: SectionHeaderView, coordinator: Void) {
        content.apply(item: item)
    }
}

final class SectionHeaderView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        titleLabel.textColor = .label
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    func apply(item: SectionHeaderComponent.Item) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        subtitleLabel.isHidden = item.subtitle == nil
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        autoLayoutFittingSize(for: size)
    }
}
