//
//  BottomMenuItemView.swift
//  ContextMenu
//
//  Created by sergeymild on 09/04/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import UIKit

class BottomMenuItemView: UIView {
    let label = UILabel()
    let icon = UIImageView()
    
    init() {
        super.init(frame: .zero)
        addSubview(label)
        addSubview(icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(index: Int, item: BottomMenuItem, menuWidth: CGFloat) {
        label.text = item.title
        label.font = item.font
        label.textColor = item.color
        
        label.frame = .init(
            x: MenuConstants.menuItemHPadding,
            y: 0, width: menuWidth - MenuConstants.menuItemHPadding * 2,
            height: MenuConstants.menuItemHeight
        )
        
        icon.isHidden = true
        if let image = item.icon {
            icon.isHidden = false
            icon.image = item.iconTint != nil ? image.withRenderingMode(.alwaysTemplate) : image
            icon.frame = .init(
                x: menuWidth - MenuConstants.menuItemHPadding - MenuConstants.menuIconSize,
                y: (MenuConstants.menuItemHeight - MenuConstants.menuIconSize) / 2,
                width: MenuConstants.menuIconSize,
                height: MenuConstants.menuIconSize
            )
            
            icon.tintColor = item.iconTint

            label.frame.size.width = menuWidth - MenuConstants.menuItemHPadding - MenuConstants.menuItemHPadding - MenuConstants.menuItemTitleIconMargin - MenuConstants.menuIconSize
        }

        isUserInteractionEnabled = true
        frame = .init(
            x: 0,
            y: CGFloat(index) * MenuConstants.menuItemHeight,
            width: menuWidth,
            height: MenuConstants.menuItemHeight
        )
    }
}
