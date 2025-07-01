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
  
  func setup(y: CGFloat, item: BottomMenuItem, menuWidth: CGFloat) {
    label.text = item.title
    label.font = item.font
    label.textColor = item.color
    var labelWidth = menuWidth - MenuConstants.menuItemHPadding * 2
    
    icon.isHidden = true
    if let image = item.icon {
      icon.isHidden = false
      icon.image = image.withRenderingMode(.alwaysTemplate)
      icon.frame = .init(
        x: menuWidth - MenuConstants.menuItemHPadding - item.iconSize,
        y: (MenuConstants.menuItemHeight - item.iconSize) / 2,
        width: item.iconSize,
        height: item.iconSize
      )
      
      icon.tintColor = item.iconTint
      
      labelWidth = menuWidth - MenuConstants.menuItemHPadding - MenuConstants.menuItemHPadding - MenuConstants.menuItemTitleIconMargin - item.iconSize
    }
    
    isUserInteractionEnabled = true
    
    var labelX = MenuConstants.menuItemHPadding
    if MenuConstants.leadingIcons {
      icon.frame.origin.x = MenuConstants.menuItemHPadding
      labelX = icon.frame.maxX + MenuConstants.menuItemHPadding
    }
    
    label.frame = .init(
      x: labelX,
      y: 0,
      width: labelWidth,
      height: MenuConstants.menuItemHeight
    )
    
    frame = .init(
      x: 0,
      y: y,
      width: menuWidth,
      height: MenuConstants.menuItemHeight
    )
  }
}
