//
//  TopMenuItemView.swift
//  ContextMenu
//
//  Created by sergeymild on 09/04/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import UIKit

class TopMenuItemView: UIView {
    let icon = UIImageView()
    
    init() {
        super.init(frame: .zero)
        addSubview(icon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(index: Int, item: TopMenuItem) {
        icon.image = item.icon
        icon.contentMode = .scaleAspectFit
        icon.frame = .init(
            x: 0,
            y: 0,
            width: MenuConstants.topMenuItemSize,
            height: MenuConstants.topMenuItemSize
        )

        isUserInteractionEnabled = true
        frame = .init(
            x: index == 0 ? MenuConstants.menuItemHPadding : (CGFloat(index) * MenuConstants.topMenuItemSize) + MenuConstants.menuItemHPadding,
            y: (MenuConstants.topMenuHeight - MenuConstants.topMenuItemSize) / 2,
            width: MenuConstants.topMenuItemSize,
            height: MenuConstants.topMenuItemSize
        )
    }
}
