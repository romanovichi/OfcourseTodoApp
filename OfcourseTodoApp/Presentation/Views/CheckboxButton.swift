//
//  CheckboxButton.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 18.11.2024.
//

import UIKit

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
