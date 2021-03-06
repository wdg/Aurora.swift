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

import Foundation
#if canImport(UIKit) && !os(watchOS)
import UIKit

/// A Designable UIGreenButton
@IBDesignable open class UIGreenButton: UIButton {
    /// A Designable UIGreenButton
    /// - Parameter frame: button frame
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// Awake from nib
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        setTitleColor(.white, for: .normal)
        
        backgroundColor = .button
        
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        
        updateFocusIfNeeded()
    }
    
    /// Init (coder)
    /// - Parameter coder: coder
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
#endif
