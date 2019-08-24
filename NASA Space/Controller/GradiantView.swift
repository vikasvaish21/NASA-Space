//
//  GradiantView.swift
//  NASA Space
//
//  Created by vikas on 24/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import Foundation
import UIKit
class GradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
    }
}
