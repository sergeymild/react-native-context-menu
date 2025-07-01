
import UIKit
import React

func fetchIcon(url: String?) -> UIImage? {
    var icon: UIImage?
    if let i = url,
       let url = URL(string: i),
       let data = try? Data(contentsOf: url) {
        icon = UIImage(data: data)
    }
    return icon
}

func uiFont(_ size: Any?) -> UIFont {
    var w: UIFont.Weight = .regular
    return UIFont.systemFont(
        ofSize: RCTConvert.cgFloat(size),
        weight: w
    )
}

func uiColor(_ value: Any?) -> UIColor? {
    guard let value else { return nil }
    return RCTConvert.uiColor(value)
}

private func convertMenu(items: [[AnyHashable : Any]]?) -> [BottomMenuItem] {
    guard let items else { return [] }
    var menuItems: [BottomMenuItem] = []

    for item in items {
        menuItems.append(.init(
            id: item["id"] as! String,
            title: item["title"] as! String,
            icon: fetchIcon(url: item["icon"] as? String),
            font: uiFont(item["titleSize"]),
            color: uiColor(item["color"]) ?? .black,
            iconSize: item["iconSize"] as? CGFloat ?? MenuConstants.menuIconSize,
            iconTint: uiColor(item["iconTint"]) ?? .black,
            submenu: convertMenu(items: RCTConvert.nsDictionaryArray(item["submenu"]))
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

        MenuConstants.menuBackgroundColor = RCTConvert.uiColor(options["menuBackgroundColor"])
        MenuConstants.menuMinWidth = RCTConvert.cgFloat(options["minWidth"])
        MenuConstants.menuItemHeight = RCTConvert.cgFloat(options["menuItemHeight"])
        MenuConstants.menuCornerRadius = RCTConvert.cgFloat(options["menuCornerRadius"])
        MenuConstants.safeAreaBottom = RCTConvert.cgFloat(options["safeAreaBottom"])

        let bottomMenuItems = RCTConvert.nsDictionaryArray(options["bottomMenuItems"])!

        menuRenderer.showMenu(
            targetView: targetView,
            viewTargetedRect: RCTConvert.cgRect(options["rect"]),
            separatorColor: RCTConvert.uiColor(options["separatorColor"]),
            separatorHeight: RCTConvert.cgFloat(options["separatorHeight"]),
            disableBlur: RCTConvert.bool(options["disableBlur"]),
            topMenuItems: [],
            bottomMenu: convertMenu(items: bottomMenuItems)
        )

        menuRenderer.onMenuItemPress = { id, index in
            let menuItem = menuRenderer.bottomMenuItems[index]
            if let submenu = menuItem.submenu, !submenu.isEmpty {
                return submenu
            }
            callback([id])
            return nil
        }
    }
}
