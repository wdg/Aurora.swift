// Aurora framework for Swift
//
// The **Aurora.framework** contains a base for your project.
//
// It has a lot of extensions built-in to make development easier.
//
// - Version: 1.0
// - Copyright: [Wesley de Groot](https://wesleydegroot.nl) ([WDGWV](https://wdgwv.com))\
//  and [Contributors](https://github.com/AuroraFramework/Aurora.swift/graphs/contributors).
//
// Please note: this is a beta version.
// It can contain bugs, please report all bugs to https://github.com/AuroraFramework/Aurora.swift
//
// Thanks for using!
//
// Licence: Needs to be decided.

#if os(iOS) || os(tvOS)

import UIKit

public extension UIScreen {
    /// Get the screen's size.
    @objc class var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    /// Get the screen's width.
    @objc class var width: CGFloat {
        UIScreen.main.bounds.size.width
    }
    
    /// Get the screen's height..
    @objc class var height: CGFloat {
        UIScreen.main.bounds.size.height
    }
    
    #if os(iOS)
    /// Get the status bar height.
    /// - Returns: The status bar height.
    class var statusBarHeight: CGFloat {
        UIApplication.shared.statusBarFrame.height
    }
    
    /// Get the screen height without the status bar.
    class var heightWithoutStatusBar: CGFloat {
        currentOrientation.isPortrait ? height - statusBarHeight :
        UIScreen.main.bounds.size.width - statusBarHeight
    }
    
    #if !os(tvOS)
    /// Get the current screen orientation.
    @objc class var currentOrientation: UIInterfaceOrientation {
        UIApplication.shared.statusBarOrientation
    }
    #endif
    #endif
}
#endif
