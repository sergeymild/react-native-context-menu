//
//  TopMenuItemView.swift
//  ContextMenu
//
//  Created by sergeymild on 09/04/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//

import UIKit

struct TopMenuItem {
    let id: String
    var icon: UIImage? = nil
    var iconTint: UIColor? = nil
    var emoji: String? = nil
}

class TopMenuItemView: UIView {
  let icon = UIImageView()
  let emoji = UILabel()
  
  init() {
    super.init(frame: .zero)
    addSubview(icon)
    addSubview(emoji)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup(index: Int, item: TopMenuItem) {
    if let i = item.icon {
      icon.image = i
      icon.tintColor = item.iconTint
      icon.contentMode = .scaleAspectFit
      icon.frame = .init(
        x: 0,
        y: 0,
        width: MenuConstants.topMenuItemSize,
        height: MenuConstants.topMenuItemSize
      )
      frame = .init(
        x: 0,
        y: 0,
        width: MenuConstants.topMenuItemSize,
        height: MenuConstants.topMenuItemSize
      )
    }
    if let i = item.emoji {
      emoji.text = i
      emoji.font = .systemFont(ofSize: MenuConstants.topMenuItemSize)
      emoji.sizeToFit()
      frame.size = emoji.frame.size
    }
    
    isUserInteractionEnabled = true
    
  }
}
