
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
        
        var items: [BottomMenuItem] = []
        
        let bottomMenuItems = RCTConvert.nsDictionaryArray(options["bottomMenuItems"])!
        for item in bottomMenuItems {
            items.append(.init(
                id: item["id"] as! String,
                title: item["title"] as! String,
                icon: fetchIcon(url: item["icon"] as? String),
                font: RCTConvert.uiFont(item["font"]),
                color: RCTConvert.uiColor(item["color"]),
                iconTint: RCTConvert.uiColor(item["iconTint"])
            ))
        }
        
        menuRenderer.showMenu(
            targetView: targetView,
            viewTargetedRect: RCTConvert.cgRect(options["rect"]),
            bottomMenu: items
        )
        
        menuRenderer.onMenuItemPress = { id in
            callback([id])
        }
    }
}
