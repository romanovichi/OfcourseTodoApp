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
    private let checkmarkLabel = CheckboxButton()
    
    var model: TaskListCellViewModel?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .systemBrown
        self.contentView.isOpaque = true

        // containerView setup
        containerView.isOpaque = true
        containerView.image = .cellBackground
        containerView.isUserInteractionEnabled = true
        contentView.addSubview(containerView)
        
        // titleLabel setup
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.backgroundColor = .systemOrange
        titleLabel.isOpaque = true
        containerView.addSubview(titleLabel)
        
        // checkmarkLabel setup
//        checkmarkLabel.font = .boldSystemFont(ofSize: 20)
//        checkmarkLabel.textAlignment = .right
//        checkmarkLabel.backgroundColor = .systemOrange
        checkmarkLabel.isOpaque = true
        containerView.addSubview(checkmarkLabel)
//        checkmarkLabel.addTarget(self, action: #selector(didTapCompleteTaskButton), for: .touchUpInside)
    }
    
    @objc func didTapCompleteTaskButton() {
        model?.completeTask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        let padding: CGFloat = 5
        let contentPadding: CGFloat = 10
        let checkmarkWidth: CGFloat = 30
        
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
            y: containerView.bounds.height / 2 - checkmarkWidth / 2,
            width: checkmarkWidth,
            height: checkmarkWidth
        )
    }
    
    // MARK: - Configuration
    func configure(with model: TaskListCellViewModel) {
        self.model = model
        titleLabel.text = model.title
        checkmarkLabel.isChecked = model.isCompleted
        checkmarkLabel.delegate = model
    }
}

protocol CheckboxButtonOutput {
    func didTapCheckbox()
}

class CheckboxButton: UIView {
    
    // MARK: - Properties
    private var hitArea = UIView()
    private let checkmarkLayer = CAShapeLayer()
    
    var delegate: CheckboxButtonOutput?
    
    var isChecked: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.backgroundColor = .clear
        
        checkmarkLayer.strokeColor = UIColor.black.cgColor
        checkmarkLayer.lineWidth = 1
        checkmarkLayer.fillColor = UIColor.clear.cgColor
        checkmarkLayer.lineCap = .round
        checkmarkLayer.lineJoin = .round
        checkmarkLayer.isHidden = true
        layer.addSublayer(checkmarkLayer)
        
        hitArea.backgroundColor = .clear
        hitArea.isUserInteractionEnabled = true
        addSubview(hitArea)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        hitArea.addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCheckmarkPath()
        
        let hitAreaPadding: CGFloat = 10
        hitArea.frame = CGRect(
            x: -hitAreaPadding,
            y: -hitAreaPadding,
            width: bounds.width + hitAreaPadding * 2,
            height: bounds.height + hitAreaPadding * 2
        )
    }
    
    private func updateCheckmarkPath() {
        let path = UIBezierPath()
        let insetBounds = bounds.insetBy(dx: bounds.width * 0.2, dy: bounds.height * 0.2)
        
        path.move(to: CGPoint(x: insetBounds.minX * 1.1, y: insetBounds.midY))
        path.addLine(to: CGPoint(x: insetBounds.midX, y: insetBounds.maxY))
        path.addLine(to: CGPoint(x: insetBounds.maxX, y: insetBounds.minY + insetBounds.height * 0.1))
        
        checkmarkLayer.path = path.cgPath
    }
    
    // MARK: - Appearance Update
    private func updateAppearance() {
        checkmarkLayer.isHidden = !isChecked
    }
    
    // MARK: - Actions
    @objc private func didTapCheckbox() {
        isChecked.toggle()
        updateAppearance()
        delegate?.didTapCheckbox()
    }
}
