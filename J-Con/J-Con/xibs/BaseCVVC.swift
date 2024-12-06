//
//  BaseCVVC.swift
//  j-lingo
//
//  Created by as on 8/8/24.
//

import UIKit


class BaseCVVC: UIViewController {
    
    @IBOutlet weak var TitleLbl: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var cvHolderView: UIView!
    @IBOutlet weak var parentHolderView: UIView!
    @IBOutlet weak var redview: CurvedHeaderView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var redviewheight: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavBar()
        setup()
    }
    
   
    
  
    private func setup() {
        self.backBtn.tintColor = .white
        self.menuBtn.tintColor = .white
        self.menuBtn.isHidden = true
        self.redview.curveType = 2
        self.redview.curveHeight = 160
    }

    override func loadView() {
        if let nibView = Bundle.main.loadNibNamed("BaseCVVC", owner: self, options: nil)?.first as? UIView {
            self.view = nibView
        }
    }
   
    private func hideNavBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func tappedBackBtn(_ sender: Any) {
    
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedmenu(_ sender: Any) {
    
        
    }
    
    func createColumnFlowLayout(cellsPerRow: Int = 2,
                                       minimumInteritemSpacing: CGFloat = 5,
                                       minimumLineSpacing: CGFloat = 5,
                                       sectionInset: UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 5, right: 10)) -> ColumnFlowLayout {
        
        let columnLayout = ColumnFlowLayout(
                cellsPerRow: cellsPerRow,
                minimumInteritemSpacing: minimumInteritemSpacing,
                minimumLineSpacing: minimumLineSpacing,
                sectionInset:sectionInset
                    
            )
        
        return columnLayout
        
    }
}
