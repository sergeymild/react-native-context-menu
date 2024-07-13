import UIKit

private var flexLayoutAssociatedObjectHandle = 72_399_923
private var flexLayoutAssociatedId = 72_399_924

extension UIView {
    public var flex: Flex {
        if let flex = objc_getAssociatedObject(self, &flexLayoutAssociatedObjectHandle) as? Flex {
            return flex
        } else {
            let flex = Flex(view: self)
            objc_setAssociatedObject(self, &flexLayoutAssociatedObjectHandle, flex, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return flex
        }
    }

    public var isFlexEnabled: Bool {
        (objc_getAssociatedObject(self, &flexLayoutAssociatedObjectHandle) as? Flex) != nil
    }

    public var flexId: String? {
        get {
            return objc_getAssociatedObject(self, &flexLayoutAssociatedId) as? String
        }
        set {
            objc_setAssociatedObject(self, &flexLayoutAssociatedId, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
