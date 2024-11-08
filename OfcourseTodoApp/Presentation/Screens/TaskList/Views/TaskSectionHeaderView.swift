//
//  TaskSectionHeaderView.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 08.11.2024.
//

import UIKit

class TaskSectionHeaderView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        addSubview(titleLabel)
        backgroundColor = .systemBrown
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labelHeight: CGFloat = 30
        let labelX: CGFloat = 16
        let labelWidth: CGFloat = frame.width - 2 * labelX
        titleLabel.frame = CGRect(x: labelX, y: (frame.height - labelHeight) / 2, width: labelWidth, height: labelHeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
