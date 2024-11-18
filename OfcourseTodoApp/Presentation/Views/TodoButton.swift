//
//  TodoButton.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 06.11.2024.
//

import UIKit

class TodoButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
                self.updateStateFor(self.isSelected)
            })
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func updateStateFor(_ isSelected: Bool) {
        backgroundColor = isSelected ? .systemOrange : .systemBrown
    }
    
    private func setupButton() {
        updateStateFor(isSelected)
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.systemOrange.cgColor
        self.layer.borderWidth = 1
        self.setTitleColor(.black, for: .normal)
    }
}
