//
//  TabCellSBrowser.swift
//  SBrowser
//
//  Created by Jin Xu on 22/01/20.
//  Copyright © 2020 SBrowser. All rights reserved.
//

import UIKit

protocol TabCellSBrowserDelegate: class {
    func close(_ sender: TabCellSBrowser)
}

class TabCellSBrowser: UICollectionViewCell, UIGestureRecognizerDelegate {

    class var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    static let reuseIdentifier = String(describing: self)

    @IBOutlet weak var title: UILabel!

    @IBOutlet weak var container: UIView!

    weak var delegate: TabCellSBrowserDelegate?

    private lazy var panGr: UIPanGestureRecognizer = {
        let gr = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
        gr.delegate = self

        return gr
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }


    // MARK: Actions

    @IBAction func close() {
        delegate?.close(self)
    }


    // MARK: UIGestureRecognizerDelegate

    /**
    First step: Allow scrolling gestures on the UICollectionView simultanously.
    */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return (gestureRecognizer == panGr && otherGestureRecognizer.view is UICollectionView)
            || (gestureRecognizer.view is UICollectionView && otherGestureRecognizer == panGr)
    }

    /**
    Second step: Don't do our pan while the UICollectionView scroll is running simultanously.
    */
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return (gestureRecognizer == panGr && otherGestureRecognizer.view is UICollectionView)
    }


    // MARK: Private Methods

    private func setup() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 8
        layer.masksToBounds = false

        addGestureRecognizer(panGr)
    }

    private var originalCenter: CGPoint!

    @objc func pan(_ gr: UIPanGestureRecognizer) {
        let trans = gr.translation(in: self)

        switch gr.state {
        case .began:
            originalCenter = center

            // A close swipe always needs to be in the up direction.
            if trans.y < 0 {
                center = CGPoint(x: originalCenter.x + trans.x, y: originalCenter.y + trans.y)
            } else {
                // 3rd step: Cancel this recognizer, when swipe is down instead of up.
                // UICollectionView scroll should take over.
                panGr.isEnabled = false
                panGr.isEnabled = true
            }

        case .changed:
            center = CGPoint(x: originalCenter.x + trans.x, y: originalCenter.y + trans.y)

        case .ended:
            // Detect a close swipe, when tab was swiped completely over original position,
            // or over 0, for the first tab row.
            if center.y < max(0, originalCenter.y - bounds.height) {
                delegate?.close(self)
            } else {
                center = originalCenter
            }

        default:
            center = originalCenter
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = ""
        for v in container.subviews {
            v.removeFromSuperview()
        }
        container.subviews.first?.isHidden = false
    }
    
}
