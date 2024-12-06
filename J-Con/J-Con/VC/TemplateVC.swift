//
//  TemplateVC.swift
//  J-Con
//
//  Created by Macbook Pro on 12/5/24.
//

import UIKit

final class TemplateVC : BaseCVVC {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUP()
    }
    
    private func setUP() {
        
        self.TitleLbl.text = "Templates"
        self.cv.dataSource = self
        self.cv.delegate = self
        self.cv.register(TemplateCVCell.self)
        
    }
    
}

extension TemplateVC : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "TemplateCVCell", for: indexPath) as! TemplateCVCell
        cell.txtView.text = "df"
        return cell
        
    }
}
