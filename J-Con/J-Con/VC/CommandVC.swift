//
//  CommandVC.swift
//  J-Con
//
//  Created by Macbook Pro on 11/11/24.
//

import UIKit

final class CommandVC : UIViewController {
    
    @IBOutlet weak var txtView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func submitBtnTapped(_ sender: Any) {
        
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearBtnTapped(_ sender: Any) {
        
        txtView.text = ""
    }
    
}

