//
//  Border.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 11/02/16.
//  Copyright © 2016 9elements GmbH. All rights reserved.
//

import UIKit


@objc(IMGLYBorder) public class Border: NSObject {

    /// The image is used as thumbnail.
    public let thumbnail: UIImage?

    /// The label that is used for accessibility.
    public let label: String?

    private var ratioToImageMap = [Float : UIImage]()

    /**
     :nodoc:
     */
    public init(thumbnail: UIImage?, label: String?) {
        self.thumbnail = thumbnail
        self.label = label
        super.init()
    }

    /**
     Get a border image matching the aspect ratio.

     - parameter ratio:     The desired ratio.
     - parameter tolerance: The tolerance that is used to pick the correct border image based on the aspect ratio.

     - returns: A border image.
     */
    public func imageForRatio(ratio: Float, tolerance: Float) -> UIImage? {
        var matchingRatio: Float = 0.0
        for keyRatio in ratioToImageMap.keys {
            if (keyRatio - tolerance) <= ratio && ratio <= (keyRatio + tolerance) {
                matchingRatio = keyRatio
                print(matchingRatio)
            }
        }
        return ratioToImageMap[matchingRatio]
    }

    /**
     Add an image that is used as a border for a ratio.

     - parameter image: A image.
     - parameter ratio: A aspect ratio.
     */
    public func addImage(image: UIImage, ratio: Float) {
        ratioToImageMap[ratio] = image
    }
}
