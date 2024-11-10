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
    
    @IBOutlet weak var jconImg: UIImageView!
    
    @IBOutlet weak var audioLbl: UILabel!
    
    @IBOutlet weak var txtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playGif()
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
        audioLbl.text = "\(audioURL)"
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            
            
        }
       
    }
    
   
    // Delegate method to handle cancellation
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("User canceled file picker")
    }
    
    private func playGif() {
        
        if let gifPath = Bundle.main.path(forResource: "J-CON", ofType: "gif"),
           let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath)) {
            let animatedImage = SDAnimatedImage(data: gifData)
            jconImg.image = animatedImage
        }
    }
}

extension HomeVC {
    
    
}
