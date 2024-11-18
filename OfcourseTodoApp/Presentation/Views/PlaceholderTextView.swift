//
//  PlaceholderTextView.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 08.11.2024.
//

import UIKit

class PlaceholderTextView: UITextView {
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.placeholderText
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var placeholder: String? {
        get { placeholderLabel.text }
        set { placeholderLabel.text = newValue }
    }
    
    override var text: String! {
        didSet {
            updatePlaceholderVisibility()
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholder()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlaceholder()
    }
    
    private func setupPlaceholder() {
        addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        
        updatePlaceholderVisibility()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func textDidChange() {
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}
