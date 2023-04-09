
import UIKit
import React

@objc(ContextMenu)
class ContextMenu: RCTViewManager {
    override var methodQueue: DispatchQueue! {
        return .main
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
                icon: RCTConvert.uiImage(item["icon"]),
                font: RCTConvert.uiFont(item["font"])
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
