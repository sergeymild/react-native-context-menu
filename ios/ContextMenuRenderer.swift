//
//  ContextMenuRenderer.swift
//  ContextMenu
//
//  Created by sergeymild on 09/04/2023.
//  Copyright © 2023 Facebook. All rights reserved.
//


import UIKit
import GestureRecognizerClosures

let menuRenderer = ContextMenuRenderer()

class ContextMenuRenderer {
    open var viewTargeted: UIView?
    open var viewTargetedRect: CGRect?
    private var scrollView: UIScrollView?
    private var blurEffectView = UIVisualEffectView()
    private var targetedImageView = UIImageView()
    private var menuView = UIView()
    private var topMenuView: UIView?
    private var customViewHeight: CGFloat = 0
    private var bottomMenuItems: [BottomMenuItem] = []
    private var topMenuItems: [TopMenuItem] = []
    var onMenuItemPress: ((String) -> Void)? = nil
    
    
    private var mainViewRect : CGRect = .zero
    private var window: UIWindow?
    
    private var safeTop: CGFloat {
        get { window!.safeAreaInsets.top }
    }
    
    private var safeBottom: CGFloat {
        get {
            MenuConstants.safeAreaBottom == 0
            ? window!.safeAreaInsets.bottom
            : MenuConstants.safeAreaBottom
        }
    }
    
    private var screenHeight: CGFloat {
        get { window!.frame.height }
    }
    
    private var screenWidth: CGFloat {
        get { window!.frame.width }
    }
    
    private var maxWidth: CGFloat {
        get { window!.frame.width - MenuConstants.menuHMargin * 2 }
    }
    
    private var maxBottom: CGFloat {
        get { window!.frame.height - safeBottom }
    }
    
    private var _viewTargetedRect: CGRect {
        get {
            if let v = viewTargeted {
                let origin = v.convert(mainViewRect.origin, to: nil)
                return .init(origin: origin, size: v.frame.size)
            } else if let g = viewTargetedRect {
                return g
            }
            fatalError("must be present either viewTargeted or viewTargetedRect")
        }
    }
    
    private var targetRect: CGPoint {
        get {
            var top = safeTop + (topMenuItems.isEmpty ? 0 : MenuConstants.topMenuHeight)
            if viewTargeted == nil { top -= safeTop }
            let r = _viewTargetedRect
            return .init(x: r.origin.x, y: max(top, r.origin.y))
        }
    }
    
    private var bottomMenuHeight: CGFloat {
        get { CGFloat(bottomMenuItems.count) * MenuConstants.menuItemHeight }
    }
    
    // MARK:- Get Rendered Image Functions
    private func getRenderedImage(afterScreenUpdates: Bool = false) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: viewTargeted!.bounds.size)
        let viewSnapShotImage = renderer.image { ctx in
            //viewTargeted.contentScaleFactor = 3
            viewTargeted!.drawHierarchy(
                in: viewTargeted!.bounds,
                afterScreenUpdates: afterScreenUpdates
            )
        }
        return viewSnapShotImage
    }
    
    open func showMenu(
        targetView: UIView? = nil,
        viewTargetedRect: CGRect? = nil,
        animated: Bool = true,
        topMenuItems: [TopMenuItem] = [],
        bottomMenu: [BottomMenuItem]
    ) {
        
        self.viewTargeted = targetView
        self.viewTargetedRect = viewTargetedRect
        self.bottomMenuItems = bottomMenu
        self.topMenuItems = topMenuItems
        DispatchQueue.main.async {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let c = UIViewController()
            self.scrollView = UIScrollView()
            c.view.addSubview(self.scrollView!)
            self.window!.rootViewController = c
            self.window!.windowLevel = .alert
            self.mainViewRect = self.window!.frame
            
            self.addBlurEffectView()
            self.addTargetedImageView()
            self.addMenu()
            self.addTopMenu()
            self.setupScrollViewContentSize()
            self.openMenu()
        }
    }
    
    func addTopMenu() {
        let rect = targetRect
        if (topMenuItems.isEmpty) { return }
        topMenuView = UIView()
        let scrollView = UIScrollView()
        topMenuView?.addSubview(scrollView)
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView?.addSubview(topMenuView!)
        
        var menuWidth: CGFloat = 0
        menuWidth = CGFloat(topMenuItems.count) * MenuConstants.topMenuItemSize + MenuConstants.menuItemHPadding * 2
        
        scrollView.contentSize = .init(width: menuWidth, height: MenuConstants.topMenuHeight)
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        
        menuWidth = min(maxWidth, menuWidth)
        
        topMenuView!.backgroundColor = MenuConstants.menuBackgroundColor
        topMenuView!.layer.cornerRadius = MenuConstants.menuCornerRadius
        topMenuView!.layer.shadowColor = UIColor.black.cgColor
        topMenuView!.layer.shadowRadius = 16
        topMenuView!.layer.shadowOpacity = 0
        
        var index = 0
        for item in topMenuItems {
            let v = TopMenuItemView()
            v.setup(index: index, item: item)
            scrollView.addSubview(v)
            index += 1
            v.onTap { [onMenuItemPress, closeAllViews] _ in
                closeAllViews()
                onMenuItemPress?(item.id)
            }
        }
        
        
        let x = max(
            MenuConstants.menuHMargin,
            rect.x + _viewTargetedRect.width - menuWidth
        )
        let y = rect.y - MenuConstants.topMenuHeight - MenuConstants.menuVMargin
        topMenuView!.frame = .init(
            origin: .init(x: x, y: y),
            size: .init(
                width: menuWidth,
                height: MenuConstants.topMenuHeight
            )
        )
        scrollView.frame = .init(origin: .zero, size: topMenuView!.frame.size)
        customViewHeight += topMenuView!.frame.maxY
    }
    
    func addMenu() {
        let rect = targetRect
        scrollView?.addSubview(menuView)
        menuView.backgroundColor = MenuConstants.menuBackgroundColor
        menuView.layer.cornerRadius = MenuConstants.menuCornerRadius
        
        var maxWidth = longestMenuItem(
            items: bottomMenuItems,
            maxWidth: maxWidth
        )
        maxWidth = max(MenuConstants.menuMinWidth, maxWidth)
        maxWidth = min(MenuConstants.menuMaxWidth, maxWidth)
        
        var x = max(
            MenuConstants.menuHMargin,
            rect.x + _viewTargetedRect.width - maxWidth
        )
        if x + maxWidth >= screenWidth {
            x = screenWidth - maxWidth - MenuConstants.menuHMargin
        }

        var y = _viewTargetedRect.height + rect.y + MenuConstants.menuVMargin
        
        if viewTargeted == nil {
            if y > maxBottom {
                y = maxBottom - bottomMenuHeight - MenuConstants.menuVMargin
            }
        }
        
        menuView.frame = .init(
            origin: .init(x: x, y: y),
            size: .init(width: maxWidth, height: bottomMenuHeight)
        )
        
        var index = 0
        for item in bottomMenuItems {
            let v = BottomMenuItemView()
            v.setup(index: index, item: item, menuWidth: maxWidth)
            menuView.addSubview(v)
            index += 1
            menuView.isUserInteractionEnabled = true
            v.onTap { [onMenuItemPress, closeAllViews] _ in
                closeAllViews()
                onMenuItemPress?(item.id)
            }
        }
        
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowRadius = 12
        menuView.layer.shadowOpacity = 0
        
        customViewHeight += menuView.frame.height
        customViewHeight += MenuConstants.menuVMargin
    }

    func addTargetedImageView() {
        scrollView?.addSubview(targetedImageView)
        
        let rect = targetRect
        
        if viewTargeted == nil {
            targetedImageView.frame = .init(origin: _viewTargetedRect.origin, size: .zero)
            return
        }
        
        
        
        targetedImageView.image = self.getRenderedImage(afterScreenUpdates: true)
        targetedImageView.frame = CGRect(
            x: rect.x,
            y: rect.y,
            width: _viewTargetedRect.width,
            height: _viewTargetedRect.height
        )
        targetedImageView.layer.shadowColor = UIColor.black.cgColor
        targetedImageView.layer.shadowRadius = 16
        targetedImageView.layer.shadowOpacity = 0
        targetedImageView.isUserInteractionEnabled = true
        customViewHeight = _viewTargetedRect.height
    }
    
    func setupScrollViewContentSize() {
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.contentInsetAdjustmentBehavior = .never
        scrollView?.frame = .init(origin: .zero, size: window!.frame.size)
        let bottom = window!.safeAreaInsets.bottom
        let top = window!.safeAreaInsets.top
        let maxHeight = UIScreen.main.bounds.height - bottom - top
        let menuBottom = menuView.frame.maxY
        var height = menuBottom
        if menuBottom > maxBottom {
            height += bottom
        }
        
        
        
        if maxHeight >= customViewHeight {
            scrollView?.isScrollEnabled = false
        } else {
            var topMenuHeight: CGFloat = 0
            if let m = topMenuView {
                m.removeFromSuperview()
                window?.rootViewController?.view.addSubview(m)
                topMenuHeight = m.frame.height
            }

            if topMenuHeight + targetedImageView.frame.height + menuView.frame.height < (screenHeight - safeTop - safeBottom) {
                menuView.frame.origin.y = screenHeight - bottom - menuView.frame.height
                targetedImageView.frame.origin.y = menuView.frame.origin.y - targetedImageView.frame.height - MenuConstants.menuVMargin
                topMenuView?.frame.origin.y = targetedImageView.frame.origin.y - topMenuHeight - MenuConstants.menuVMargin
                height = topMenuHeight + targetedImageView.frame.height + menuView.frame.height
            } else {
                topMenuView?.frame.origin.y = safeTop
                targetedImageView.frame.origin.y = topMenuHeight + MenuConstants.menuVMargin + safeTop
                menuView.frame.origin.y = targetedImageView.frame.maxY + MenuConstants.menuVMargin
                height = menuView.frame.maxY + bottom
            }
            
            
            
        }
        
        scrollView?.contentSize = .init(
            width: window!.frame.width,
            height: height
        )
        scrollView?.onTap { [closeAllViews] _ in closeAllViews() }

        DispatchQueue.main.async {
            self.scrollView?.scrollToBottom()
        }
    }
    
    
    func addBlurEffectView() {
        if viewTargeted == nil { return }
        window?.rootViewController?.view.insertSubview(blurEffectView, at: 0)
        
        blurEffectView.effect = MenuConstants.blurEffectDefault
        blurEffectView.backgroundColor = .clear
        
        blurEffectView.frame = CGRect(
            x: mainViewRect.origin.x,
            y: mainViewRect.origin.y,
            width: mainViewRect.width,
            height: mainViewRect.height
        )
    }
    
    @objc
    func dismissViewAction(_ sender: UITapGestureRecognizer? = nil){
        closeAllViews()
    }
    
    func closeAllViews() {
        DispatchQueue.main.async {
            //self.targetedImageView.isUserInteractionEnabled = false
            //self.menuView.isUserInteractionEnabled = false
            let rect = self.targetRect
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.layoutSubviews, .preferredFramesPerSecond60, .allowUserInteraction], animations: {
                self.prepareViewsForRemoveFromSuperView(with: rect)
                //                self.menuView.transform = CGAffineTransform.identity.scaledBy(x: 0, y: 0)//.translatedBy(x: 0, y: (self.menuHeight) * CGFloat((rect.y < self.menuView.frame.origin.y) ? -1 : 1) )
                
            }) { (_) in
                DispatchQueue.main.async {
                    self.removeAllViewsFromSuperView()
                }
            }
        }
    }
    
    func openMenu() {
        window!.makeKeyAndVisible()
        topMenuView?.alpha = 0
        menuView.alpha = 0
        blurEffectView.alpha = 0
        targetedImageView.alpha = 1
        
        targetedImageView.layer.shadowOpacity = 0.0
        //targetedImageView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = 1
            self.topMenuView?.alpha = 1
            self.blurEffectView.alpha = 1
            self.targetedImageView.layer.shadowOpacity = 0.2
            self.topMenuView?.layer.shadowOpacity = 0.2
            self.menuView.layer.shadowOpacity = 0.2
        }
    }
    
    func prepareViewsForRemoveFromSuperView(with rect: CGPoint) {
        blurEffectView.alpha = 0
        targetedImageView.alpha = 0
        targetedImageView.layer.shadowOpacity = 0
        self.topMenuView?.layer.shadowOpacity = 0
        targetedImageView.frame = CGRect(
            x: rect.x,
            y: rect.y,
            width: _viewTargetedRect.width,
            height: _viewTargetedRect.height
        )
        menuView.alpha = 0
        topMenuView?.alpha = 0
        menuView.layer.shadowOpacity = 0
    }
    
    func removeAllViewsFromSuperView() {
        viewTargeted?.alpha = 1
        viewTargeted = nil
        viewTargetedRect = .zero
        targetedImageView.alpha = 0
        targetedImageView.removeFromSuperview()
        targetedImageView.image = nil
        blurEffectView.removeFromSuperview()
        menuView.removeFromSuperview()
        menuView.subviews.forEach { $0.removeFromSuperview() }
        topMenuView?.removeFromSuperview()
        window?.removeFromSuperview()
        scrollView?.removeFromSuperview()
        scrollView = nil
        window = nil
        onMenuItemPress = nil
        topMenuView = nil
    }
}
