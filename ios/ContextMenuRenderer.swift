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
    private(set) var bottomMenuItems: [BottomMenuItem] = []
    private var topMenuItems: [TopMenuItem] = []
    private var separatorColor: UIColor? = nil
    private var separatorHeight: CGFloat? = nil
    var onMenuItemPress: ((String, Int) -> [BottomMenuItem]?)? = nil


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

    private var maxHeight: CGFloat {
        get {  UIScreen.main.bounds.height - safeTop - safeBottom }
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

    private var topMenuHeight: CGFloat {
        return topMenuView?.frame.height ?? .zero
    }

    private var allContentHeight: CGFloat {
        _viewTargetedRect.height + menuView.frame.height
    }

    private var targetRect: CGPoint {
        get {
            var top = safeTop + (topMenuItems.isEmpty ? 0 : (topMenuHeight + MenuConstants.menuVMargin))
            if viewTargeted == nil { top -= safeTop }
            let r = _viewTargetedRect
            return .init(x: r.origin.x, y: max(top, r.origin.y))
        }
    }

    private var bottomMenuHeight: CGFloat {
        get {
            var itemsHeight = CGFloat(bottomMenuItems.count) * MenuConstants.menuItemHeight
            if let sHeight = separatorHeight {
                itemsHeight += sHeight * (CGFloat(bottomMenuItems.count) - 1)
            }
            return itemsHeight
        }
    }

    // MARK:- Get Rendered Image Functions
    private func getRenderedImage(afterScreenUpdates: Bool = false) -> UIImage{
        let renderer = UIGraphicsImageRenderer(size: viewTargeted!.bounds.size)
        let viewSnapShotImage = renderer.image { ctx in
            viewTargeted!.drawHierarchy(
                in: viewTargeted!.bounds,
                afterScreenUpdates: afterScreenUpdates
            )
        }
        return viewSnapShotImage
    }

    // MARK: showMenu
    open func showMenu(
        targetView: UIView? = nil,
        viewTargetedRect: CGRect? = nil,
        separatorColor: UIColor? = nil,
        separatorHeight: CGFloat? = nil,
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
            self.separatorColor = separatorColor
            self.separatorHeight = separatorHeight
            if !MenuConstants.blurEffectEnabled { self.addBlurEffectView() }

            self.addTopMenu()
            self.addTargetedImageView()
            self.addBottomMenu()
            self.setupScrollViewContentSize()
            self.openMenu()
        }
    }

    // MARK: addTopMenu
    func addTopMenu() {
        let rect = targetRect
        if (topMenuItems.isEmpty) { return }
        topMenuView = UIView()
        self.scrollView?.addSubview(topMenuView!)

        topMenuView?.flex.maxWidth(MenuConstants.menuMaxWidth)
        topMenuView?.flex.direction(.row)
        topMenuView?.flex.wrap(.wrap)
        topMenuView?.flex.justifyContent(.center)
        topMenuView?.flex.alignItems(.center)
        topMenuView?.flex.paddingVertical(8)

        topMenuView!.backgroundColor = MenuConstants.menuBackgroundColor
        topMenuView!.layer.cornerRadius = MenuConstants.menuCornerRadius
        topMenuView!.layer.shadowColor = UIColor.black.cgColor
        topMenuView!.layer.shadowRadius = 16
        topMenuView!.layer.shadowOpacity = 0

        var index = 0
        for item in topMenuItems {
            let v = TopMenuItemView()
            v.setup(index: index, item: item)
            v.flex.isIncludedInLayout(true)
            topMenuView?.addSubview(v)
            index += 1
            v.onTap { [weak self] _ in
                self?.closeAllViews()
            }
        }

        topMenuView?.flex.layout(mode: .adjustHeight)
        let menuWidth = topMenuView?.frame.width ?? .zero


        var x = max(
            MenuConstants.menuHMargin,
            rect.x + _viewTargetedRect.width - menuWidth
        )
        let maxX = topMenuView!.frame.maxX
        if x + maxX >= screenWidth {
            x = screenWidth - MenuConstants.menuVMargin - maxX
        }

        let y = max(rect.y - topMenuHeight - MenuConstants.menuVMargin, window!.safeAreaInsets.top)
        topMenuView!.frame.origin = .init(x: x, y: y)
        customViewHeight += topMenuView!.frame.height
    }

    // MARK: addBottomMenu
    func addBottomMenu() {
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
        if x < 0 { x = MenuConstants.menuHMargin }
        if x + maxWidth >= screenWidth {
            maxWidth = screenWidth - MenuConstants.menuHMargin
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


        for (index, item) in bottomMenuItems.enumerated() {
            let isEnableSeparator = index != 0 && index != bottomMenuItems.count
            let v = BottomMenuItemView()
            var y = CGFloat(index) * MenuConstants.menuItemHeight
            if isEnableSeparator, let sHeight = separatorHeight {
                y += sHeight
            }
            v.setup(y: y, item: item, menuWidth: maxWidth)
            menuView.addSubview(v)
            menuView.isUserInteractionEnabled = true

            if isEnableSeparator, let sHeight = separatorHeight {
                let sv = UIView()
                sv.frame = .init(
                    x: 0,
                    y: y,
                    width: maxWidth,
                    height: sHeight
                )
                sv.backgroundColor = separatorColor
                menuView.addSubview(sv)
            }

            v.onTap { [weak self] _ in
                guard let self else { return }
                MenuImpactGenerator.shared.impactOccurred()
                if let subMenu = onMenuItemPress?(item.id, index) {
                    bottomMenuItems = subMenu
                    closeBottomMenu()
                    return
                }
                closeAllViews()
            }
        }

        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowRadius = 12
        menuView.layer.shadowOpacity = 0

        customViewHeight += menuView.frame.height
        customViewHeight += MenuConstants.menuVMargin
    }

    // MARK: addTargetedImageView
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

    // MARK: setupScrollViewContentSize
    func setupScrollViewContentSize() {
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.contentInsetAdjustmentBehavior = .never
        scrollView?.frame = .init(origin: .zero, size: window!.frame.size)
        let menuBottom = menuView.frame.maxY
        var height = menuBottom
        if menuBottom > maxBottom {
            height += safeBottom
        }



        debugPrint(allContentHeight, maxHeight, customViewHeight, menuView.frame.maxY)
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
                menuView.frame.origin.y = screenHeight - safeBottom - menuView.frame.height
                targetedImageView.frame.origin.y = menuView.frame.origin.y - targetedImageView.frame.height - MenuConstants.menuVMargin
                topMenuView?.frame.origin.y = targetedImageView.frame.origin.y - topMenuHeight - MenuConstants.menuVMargin
                height = topMenuHeight + targetedImageView.frame.height + menuView.frame.height
            } else {
                topMenuView?.frame.origin.y = safeTop
                targetedImageView.frame.origin.y = topMenuHeight + MenuConstants.menuVMargin + safeTop
                menuView.frame.origin.y = targetedImageView.frame.maxY + MenuConstants.menuVMargin
                height = menuView.frame.maxY + safeBottom
            }
        }

        scrollView?.contentSize = .init(
            width: window!.frame.width,
            height: height
        )
        scrollView?.onTap { [closeAllViews] _ in closeAllViews() }

        DispatchQueue.main.async {
            if self.allContentHeight >= self.maxHeight {
                self.scrollView?.scrollToTop()
            } else {
                self.scrollView?.scrollToBottom()
            }

        }
    }


    // MARK: addBlurEffectView
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

    // MARK: closeBottomMenu
    func closeBottomMenu() {
        let prevoiusMenuFrame = menuView.frame
        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = 0
        } completion: { _ in
            self.menuView.removeFromSuperview()
            self.menuView.subviews.forEach { $0.removeFromSuperview() }
            self.addBottomMenu()
            self.menuView.frame.origin = prevoiusMenuFrame.origin
            if self.menuView.frame.maxX > self.screenWidth - MenuConstants.menuHMargin {
                self.menuView.frame.origin.x = self.screenWidth - MenuConstants.menuHMargin - self.menuView.frame.width
            }

            self.menuView.alpha = 0
            UIView.animate(withDuration: 0.2) {
                self.menuView.alpha = 1
            }
        }
    }

    // MARK: closeAllViews
    func closeAllViews() {
        DispatchQueue.main.async {
            let rect = self.targetRect

            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 6, options: [.layoutSubviews, .preferredFramesPerSecond60, .allowUserInteraction], animations: {
                self.prepareViewsForRemoveFromSuperView(with: rect)
            }) { (_) in
                DispatchQueue.main.async {
                    self.removeAllViewsFromSuperView()
                }
            }
        }
    }

    // MARK: openMenu
    func openMenu() {
        window!.makeKeyAndVisible()
        topMenuView?.alpha = 0
        menuView.alpha = 0
        blurEffectView.alpha = 0
        targetedImageView.alpha = 1

        targetedImageView.layer.shadowOpacity = 0.0

        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = 1
            self.topMenuView?.alpha = 1
            self.blurEffectView.alpha = 1
            self.targetedImageView.layer.shadowOpacity = 0.2
            self.topMenuView?.layer.shadowOpacity = 0.2
            self.menuView.layer.shadowOpacity = 0.2
        }
    }

    // MARK: prepareViewsForRemoveFromSuperView
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
