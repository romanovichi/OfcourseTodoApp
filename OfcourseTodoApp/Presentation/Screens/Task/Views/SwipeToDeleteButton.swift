//
//  SwipeToDeleteButton.swift
//  OfcourseTodoApp
//
//  Created by Иван Романович on 08.11.2024.
//

import UIKit

protocol SwipeToDeleteButtonDelegate: AnyObject {
    func didTriggerDeleteAction()
}

class SwipeToDeleteButton: UIButton {
    
    private var initialColor: UIColor?
    private var overlayView: UIView!
    weak var delegate: SwipeToDeleteButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialColor = backgroundColor
        setupOverlayView()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialColor = backgroundColor
        setupOverlayView()
        setupGesture()
    }
    
    private func setupOverlayView() {
        overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.layer.cornerRadius = layer.cornerRadius
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlayView.widthAnchor.constraint(equalToConstant: 0)
        ])
    }
    
    private func setupGesture() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        addGestureRecognizer(swipeGesture)
    }
    
    @objc private func handleSwipeGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let progress = min(max(translation.x / frame.width, 0), 1)
        
        switch gesture.state {
        case .changed:
            animateOverlayView(toProgress: progress)
        case .ended:
            if progress > 0.5 {
                triggerDeleteAction()
            } else {
                resetOverlay()
            }
        case .cancelled:
            resetOverlay()
        default:
            break
        }
    }
    
    private func animateOverlayView(toProgress progress: CGFloat) {
        if let widthConstraint = overlayView.constraints.first(where: { $0.firstAttribute == .width }) {
            widthConstraint.constant = frame.width * progress
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    private func resetOverlay() {
        if let widthConstraint = overlayView.constraints.first(where: { $0.firstAttribute == .width }) {
            widthConstraint.constant = 0
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    private func triggerDeleteAction() {
        delegate?.didTriggerDeleteAction()
    }
}
