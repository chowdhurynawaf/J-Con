//
//  TemplateCVCell.swift
//  J-Con
//
//  Created by Macbook Pro on 12/6/24.
//

import UIKit

class TemplateCVCell: UICollectionViewCell,NibLoadableView {
    
    @IBOutlet weak var parentView: CustomView!
    @IBOutlet weak var txtView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    private func setup() {
        parentView.cornerRadius = 8
        parentView.borderWidth = 0.3
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setup()
    }

}
