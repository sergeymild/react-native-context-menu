//
//  BottomMenuItem.swift
//  ContextMenu
//
//  Created by sergeymild on 09/04/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import UIKit

struct BottomMenuItem {
    let id: String
    let title: String
    let icon: UIImage?
    let font: UIFont
    let color: UIColor
    let iconSize: CGFloat
    let iconTint: UIColor
    let submenu: [BottomMenuItem]?
}

struct TopMenuItem {
    let id: String
    let icon: UIImage
}


internal func longestMenuItem(items: [BottomMenuItem], maxWidth: CGFloat) -> CGFloat {
    var longestWidth: CGFloat = 0
    for item in items {
        var width: CGFloat = 0
        if !item.title.isEmpty {
            width = item.title.height(
                constraintedWidth: maxWidth,
                font: item.font ?? MenuConstants.menuItemFont
            ).width
        }
        width += MenuConstants.menuItemHPadding * 2
        if item.icon != nil {
            width += MenuConstants.menuItemTitleIconMargin
            width += item.iconSize
        }
        if width > longestWidth { longestWidth = width }
    }
    return longestWidth
}
