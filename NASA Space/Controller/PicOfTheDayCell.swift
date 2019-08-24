//
//  PicOfTheDayCell.swift
//  NASA Space
//
//  Created by vikas on 24/08/19.
//  Copyright © 2019 project1. All rights reserved.
//

import Foundation
import UIKit
class PicOfTheDayCell:UICollectionViewCell{
    
    static let reuseIdentifier: String = "cell"
    
    @IBOutlet weak var picOfTheDay: UIImageView!
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var title: UILabel!
}
