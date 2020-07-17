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

extension Aurora {
    /// <#Description#>
    /// - Parameter background: <#background description#>
    public func run(background: @escaping () -> Void) {
        DispatchQueue.global().async {
            background()
        }
    }
    
    /// <#Description#>
    /// - Parameter main: <#main description#>
    public func execute(main: @escaping () -> Void) {
        DispatchQueue.main.async {
            main()
        }
    }
    
    /// <#Description#>
    /// - Parameter background: <#background description#>
    public func execute(background: @escaping () -> Void) {
        DispatchQueue.global().async {
            background()
        }
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - after: <#after description#>
    ///   - closure: <#closure description#>
    public func delay(_ after: Double, closure: @escaping () -> Void) {
        let when = DispatchTime.now() + after
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    /// <#Description#>
    /// - Parameters:
    ///   - after: <#after description#>
    ///   - closure: <#closure description#>
    public func execute(_ after: Double, closure: @escaping () -> Void) {
        let when = DispatchTime.now() + after
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
}
