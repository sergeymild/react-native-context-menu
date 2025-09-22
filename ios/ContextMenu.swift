
import UIKit
import React

private func fetchIcon(url: String?) -> UIImage? {
  var icon: UIImage?
  if let i = url,
     let url = URL(string: i),
     let data = try? Data(contentsOf: url) {
    icon = UIImage(data: data)
  }
  return icon
}

private func uiFont(_ size: Any?, _ fontFamily: String?) -> UIFont {
  if let fontFamily, let font = UIFont(name: fontFamily, size: RCTConvert.cgFloat(size)) {
    return font
  }
  return UIFont.systemFont(
    ofSize: RCTConvert.cgFloat(size),
    weight: .regular
  )
}

private func uiColor(_ value: Any?) -> UIColor? {
  guard let value else { return nil }
  return RCTConvert.uiColor(value)
}

private func convertMenu(items: [[AnyHashable : Any]]?) -> [BottomMenuItem] {
  guard let items else { return [] }
  var menuItems: [BottomMenuItem] = []
  
  for item in items {
    menuItems.append(BottomMenuItem(
      id: item["id"] as! String,
      title: item["title"] as! String,
      icon: fetchIcon(url: item["icon"] as? String),
      font: uiFont(item["titleSize"], item["fontFamily"] as? String),
      color: uiColor(item["color"]) ?? .black,
      iconSize: item["iconSize"] as? CGFloat ?? MenuConstants.menuIconSize,
      iconTint: uiColor(item["iconTint"]) ?? .black,
      submenu: convertMenu(items: RCTConvert.nsDictionaryArray(item["submenu"]))
    ))
  }
  return menuItems
}

private func convertTopMenu(items: [[AnyHashable : Any]]?) -> [TopMenuItem] {
  guard let items else { return [] }
  var menuItems: [TopMenuItem] = []
  
  for item in items {
    menuItems.append(TopMenuItem(
      id: item["id"] as! String,
      icon: fetchIcon(url: item["icon"] as? String),
      iconTint: uiColor(item["iconTint"]),
      emoji: item["emoji"] as? String
    ))
  }
  return menuItems
}

@objc(ContextMenu)
class ContextMenu: RCTViewManager {
  override var methodQueue: DispatchQueue! {
    return .main
  }
  
  override class func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc
  func showMenu(
    _ options: NSDictionary,
    callback: @escaping RCTResponseSenderBlock
  ) {
    
    let targetId = RCTConvert.nsNumber(options["viewTargetId"])
    let targetView = bridge.uiManager.view(forReactTag: targetId)
    
    MenuConstants.menuHMargin = RCTConvert.cgFloat(options["menuEdgesMargin"])
    MenuConstants.menuBackgroundColor = RCTConvert.uiColor(options["menuBackgroundColor"])
    MenuConstants.menuMinWidth = RCTConvert.cgFloat(options["minWidth"])
    MenuConstants.menuItemHeight = RCTConvert.cgFloat(options["menuItemHeight"])
    MenuConstants.topMenuItemSize = RCTConvert.cgFloat(options["topMenuItemSize"])
    MenuConstants.menuCornerRadius = RCTConvert.cgFloat(options["menuCornerRadius"])
    MenuConstants.safeAreaBottom = RCTConvert.cgFloat(options["safeAreaBottom"])
    MenuConstants.leadingIcons = RCTConvert.bool(options["leadingIcons"])
    MenuConstants.blurEffectEnabled = RCTConvert.bool(options["disableBlur"]) != false
    
    let bottomMenuItems = RCTConvert.nsDictionaryArray(options["bottomMenuItems"])!
    let topMenuItems = RCTConvert.nsDictionaryArray(options["topMenuItems"])
    
    menuRenderer.showMenu(
      targetView: targetView,
      viewTargetedRect: RCTConvert.cgRect(options["rect"]),
      separatorColor: RCTConvert.uiColor(options["separatorColor"]),
      separatorHeight: RCTConvert.cgFloat(options["separatorHeight"]),
      topMenuItems: convertTopMenu(items: topMenuItems),
      bottomMenu: convertMenu(items: bottomMenuItems),
      gravity: RCTConvert.nsString(options["gravity"])
    )
    
    menuRenderer.onMenuItemPress = { id, index in
      let menuItem = menuRenderer.bottomMenuItems[index]
      if let submenu = menuItem.submenu, !submenu.isEmpty {
        return submenu
      }
      callback([id, "bottom"])
      return nil
    }
    menuRenderer.onTopMenuItemPress = { id in
      callback([id, "top"])
    }
  }
}
