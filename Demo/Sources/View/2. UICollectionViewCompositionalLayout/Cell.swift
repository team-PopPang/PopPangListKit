//
//  Cell.swift
//  PopPangListKit
//
//  Created by 김동현 on 7/8/26.
//

import UIKit

final class CompositionalCell: UICollectionViewCell, ReuseIdentifiable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentConfiguration = nil
        backgroundColor = .secondarySystemBackground
    }
    
    private func setUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        clipsToBounds = true
    }
    
    func configure(title: String) {
        var configuration = UIListContentConfiguration.cell()
        configuration.text = title
        contentConfiguration = configuration
    }
}

