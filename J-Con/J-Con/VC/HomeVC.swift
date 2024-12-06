//
//  HomeVC.swift
//  J-Con
//
//  Created by Macbook Pro on 11/10/24.
//

import UIKit
import SDWebImage
import MobileCoreServices

final class HomeVC: UIViewController,UIDocumentPickerDelegate , UITextFieldDelegate{
    

    @IBOutlet weak var editBtn: CustomButton!
    @IBOutlet weak var audioLbl: UILabel!
    @IBOutlet weak var txtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        audioLbl.isHidden = true
        txtField.delegate = self
        
    }
    
    
    @IBAction func uplaodBtnTapped(_ sender: Any) {
        
        presentFilePicker()
    }
    
    private func presentFilePicker() {
        // Create the document picker, allowing access to audio files
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content"], in: .import)

        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false // Allow single file selection
        
        present(documentPicker, animated: true, completion: nil)
    }
    
    // Delegate method called when a file is selected
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let audioURL = urls.first else { return }
        
        // Print or use the selected audio file URL
        print("Selected audio file URL: \(audioURL)")
        audioLbl.isHidden =  false
        audioLbl.text = "\(audioURL.lastPathComponent)"
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            
            self.gotToLoaderVC()
        }
       
    }
    
    func gotToLoaderVC() {
        pushWithData(ofType: RotatingCharacterLoaderVC.self)
    }
   
    // Delegate method to handle cancellation
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("User canceled file picker")
    }
    
    @IBAction func commandBtnTapped(_ sender: Any) {
        
        self.moveToCommandVC()
        
    }
    
    
    @IBAction func editBtnTapped(_ sender: Any) {
        
        pushViewController(ofType: TemplateVC.self)
    }
    
    
    private func moveToCommandVC() {
        
        pushWithData(ofType: CommandVC.self,storyboardName: "Main") { vc in
            
            
        }
    }
}

extension HomeVC {
    
    
}
