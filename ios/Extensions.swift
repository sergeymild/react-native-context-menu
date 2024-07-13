//
//  String+Extensions.swift
//  ContextMenu
//
//  Created by sergeymild on 09/04/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import UIKit

internal extension String {
    func height(
        constraintedWidth width: CGFloat,
        font: UIFont
    ) -> CGSize {
        let label =  UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: width,
            height: .greatestFiniteMagnitude
        ))
        label.numberOfLines = 0
        label.text = self
        label.font = font
        label.sizeToFit()
        
        return label.frame.size
    }
}

internal extension UIScrollView {
    func scrollToBottom() {
        if contentSize.height < bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: false)
    }
    
    func scrollToTop() {
        if contentSize.height < bounds.size.height { return }
        setContentOffset(.init(x: 0, y: 0), animated: false)
    }
}
