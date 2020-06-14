//
//  StatusToastView.swift
//  Vitals
//
//  Created by Eric Ziegler on 6/14/20.
//  Copyright © 2020 Zigabytes. All rights reserved.
//

import UIKit

// MARK: - Constants

let StatusToastHeight: CGFloat = 134

class StatusToastView: UIView {

    // MARK: - Properties

    @IBOutlet var statusLabel: BoldLabel!
    private var parentViewController: UIViewController!
    private var statusText: String = ""
    private var bgColor: UIColor!
    private var textColor: UIColor!

    // MARK: - Init

    class func createToastFor(parentViewController: UIViewController, status: String, backgroundColor: UIColor? = UIColor(hex: 0x63cf8f), foregroundColor: UIColor? = UIColor.white) -> StatusToastView {
        let toast: StatusToastView = UIView.fromNib()
        toast.parentViewController = parentViewController
        toast.statusText = status
        toast.bgColor = backgroundColor
        toast.textColor = foregroundColor
        return toast
    }

    // MARK: - Display

    func showToast() {
        // setup display
        statusLabel.text = statusText
        self.backgroundColor = bgColor
        self.statusLabel.textColor = textColor
        // initialize position
        let parentView = parentViewController.view!
        self.frame = CGRect(x: parentView.frame.origin.x, y: parentView.frame.origin.y - self.frame.size.height, width: parentView.frame.size.width, height: StatusToastHeight)
        parentView.superview?.addSubview(self)
        // animate in
        UIView.animate(withDuration: 0.15, animations: {
            self.frame = CGRect(x: parentView.frame.origin.x, y: parentView.frame.origin.y, width: parentView.frame.size.width, height: StatusToastHeight)
        }) { (finished) in
            if finished == true {
                UIView.animate(withDuration: 0.15, delay: 1.5, options: .curveEaseInOut, animations: {
                    self.frame = CGRect(x: parentView.frame.origin.x, y: parentView.frame.origin.y - self.frame.size.height, width: parentView.frame.size.width, height: StatusToastHeight)
                }) { (finished) in
                    if finished == true {
                        self.removeFromSuperview()
                    }
                }
            }
        }
    }

}
