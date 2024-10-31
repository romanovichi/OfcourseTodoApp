//
//  TaskListCell.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 31.10.2024.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    private var setupLayoutIsDone: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setupLayout() {
        // override to setup initial layout
    }
    
    override func layoutSubviews() {
        if !setupLayoutIsDone {
            setupLayout()
            setupLayoutIsDone = true
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


class TaskListCell: BaseTableViewCell {
    
    // MARK: - Subviews
    private let containerView = UIImageView()
    private let titleLabel = UILabel()
    private let checkmarkLabel = UILabel()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .systemBrown
        self.contentView.isOpaque = true

        // containerView setup
        containerView.isOpaque = true
        containerView.image = .cellBackground
        contentView.addSubview(containerView)
        
        // titleLabel setup
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.backgroundColor = .systemOrange
        titleLabel.isOpaque = true
        containerView.addSubview(titleLabel)
        
        // checkmarkLabel setup
        checkmarkLabel.font = .boldSystemFont(ofSize: 20)
        checkmarkLabel.textAlignment = .right
        checkmarkLabel.backgroundColor = .systemOrange
        checkmarkLabel.isOpaque = true
        containerView.addSubview(checkmarkLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        let padding: CGFloat = 5
        let contentPadding: CGFloat = 10
        let checkmarkWidth: CGFloat = 20
        
        // Layout containerView
        containerView.frame = CGRect(
            x: padding,
            y: padding,
            width: contentView.bounds.width - padding * 2,
            height: contentView.bounds.height - padding * 2
        )
        
        let containerViewWidth = containerView.bounds.width
        let contentWidth = containerViewWidth - padding * 2 - checkmarkWidth
        
        // Layout titleLabel
        titleLabel.frame = CGRect(
            x: contentPadding,
            y: 0,
            width: contentWidth,
            height: containerView.bounds.height
        )
        
        // Layout checkmarkLabel
        checkmarkLabel.frame = CGRect(
            x: containerView.bounds.width - contentPadding - checkmarkWidth,
            y: 0,
            width: checkmarkWidth,
            height: containerView.bounds.height
        )
    }
    
    // MARK: - Configuration
    func configure(with title: String, isCompleted: Bool) {
        titleLabel.text = title
        checkmarkLabel.text = isCompleted ? "✓" : ""
        checkmarkLabel.textColor = isCompleted ? .black : .clear
    }
}
