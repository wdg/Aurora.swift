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

#if os(iOS)
import Foundation
#if canImport(UIKit)
import UIKit

/// Image Slider
///
/// Warning EXPERIMENTAL
open class ImageSlider {
    /// Images
    var images: [UIImage] = []
    
    /// Image height
    var imageHeight: Int
    
    /// Page control element
    var pageControl: UIPageControl
    
    /// ScrollView element
    var scrollView: UIScrollView
    
    /// (Semi) random Colors
    var colors: [UIColor] = [
        .red,
        .orange,
        .green,
        .yellow,
        .gray,
        .cyan,
        .clear,
        .brown,
        .black
    ]
    
    /// Initialize Slider
    /// - Parameters:
    ///   - images: Images
    ///   - view: Viewcontroller
    ///   - pageControl: PageControl
    ///   - scrollView: ScrollView
    ///   - height: Image height
    public init(
        images: [UIImage],
        view: UIViewController,
        pageControl: UIPageControl,
        scrollView: UIScrollView,
        height: Int? = Int.max) {
        self.images = images
        self.imageHeight = height!
        self.pageControl = pageControl
        self.scrollView = scrollView
        
        // Screen width.
        let imageSizeAsInt = Int.init(scrollView.frame.size.width)
        let imageSizeAsFloat = scrollView.frame.size.width
        
        // Content size
        scrollView.contentSize = CGSize.init(
            width: CGFloat(imageSizeAsInt * images.count),
            height: scrollView.frame.size.height
        )
        
        scrollView.isPagingEnabled = true
        scrollView.delegate = view as? UIScrollViewDelegate
        pageControl.numberOfPages = 0
        var xPos: CGFloat = 0.0
        
        for image in images {
            let imageView = UIImageView.init(
                frame: CGRect(
                    x: xPos,
                    y: 0.0,
                    width: imageSizeAsFloat,
                    height: scrollView.frame.size.height
                )
            )
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            imageView.clipsToBounds = true
            imageView.layer.masksToBounds = true
            imageView.image = image.imageResize(
                sizeChange: CGSize(
                    width: imageSizeAsFloat,
                    height: scrollView.frame.size.height
                )
            )
            scrollView.addSubview(imageView)
            
            xPos += imageSizeAsFloat
            pageControl.numberOfPages += 1
        }
        
        // Fix scroll to bottom
        scrollView.contentSize = CGSize.init(
            width: scrollView.contentSize.width,
            height: 0
        )
    }
    
    /// Scroll
    /// - Parameters:
    ///   - scrollView: ScrollView
    ///   - view: UIViewController
    ///   - pageControl: Pagecontrol
    public func scroll(scrollView: UIScrollView, view: UIViewController, pageControl: UIPageControl) {
        let currentPage: Int = Int.init(
            floor(
                scrollView.contentOffset.x / view.view.frame.size.width
            )
        )
        //        Aurora.shared.log("CurrentPage=\(currentPage) x:\(scrollView.contentOffset.x)")
        pageControl.currentPage = currentPage
    }
}
#endif
#endif
