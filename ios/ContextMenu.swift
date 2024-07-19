
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
        
        var items: [BottomMenuItem] = []
        
        let bottomMenuItems = RCTConvert.nsDictionaryArray(options["bottomMenuItems"])!
        for item in bottomMenuItems {
            items.append(.init(
                id: item["id"] as! String,
                title: item["title"] as! String,
                icon: fetchIcon(url: item["icon"] as? String),
                font: uiFont(item["titleSize"]),
                color: RCTConvert.uiColor(item["color"]),
                iconSize: RCTConvert.cgFloat(item["iconSize"]),
                iconTint: RCTConvert.uiColor(item["iconTint"])
            ))
        }
        
        menuRenderer.showMenu(
            targetView: targetView,
            viewTargetedRect: RCTConvert.cgRect(options["rect"]),
            topMenuItems: [],
            bottomMenu: items
        )
        
        menuRenderer.onMenuItemPress = { id in
            callback([id])
        }
    }
}
