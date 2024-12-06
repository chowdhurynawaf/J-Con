import UIKit

class RotatingCharacterLoaderVC: UIViewController {
    
    @IBOutlet weak var loaderview: UIView!
    @IBOutlet weak var loaderTextView: CircularTextView!
    
    let mixed = [
        "あ", "能" , "う", "え", "お", // Hiragana
        "ア", "概", "ウ", "エ", "機", // Katakana
        "日", "本", "語", "学", "生",
        "風","家", "い","花",
        "空","雨", "オ"
    ]
    
    let hiragana = [
        "あ", "い", "う", "え", "お", // Hiragana
        "か", "き", "く", "け", "こ",
        "さ", "し", "す", "せ", "そ"
    ]
    
    let hindi = [
        "अ", "आ", "इ", "ई", "उ", // Vowels
        "ए", "ऐ", "ओ", "औ", "अं", // More vowels
        "क", "ख", "ग", "घ", "च" // Consonants
    ]

    let katakana = [
        "ア", "イ", "ウ", "エ", "オ", // Katakana
        "カ", "キ", "ク", "ケ", "コ",
        "サ", "シ", "ス"// Additional Katakana
    ]
    
    let arabic = ["ا", "ب", "ت", "ث", "ج",
                  "ح", "خ", "د", "ذ", "ر",
                  "ز", "س", "ش" // Additional letters
]

    let kanji = [
        "日", "月", "火", "水", "木", // Days of the week
        "金", "土", "犬", "虫"
    ]

    let kanjiExtra = [
       // "山", "川", "田", "花", "鳥", // Additional Kanji
        "ক","খ", "অ" ,"উ", "ঙ" , "চ", "ম"
        
    ]

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
       setLayers()
       showChangView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loaderTextView.startRotating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loaderTextView.stopRotating()
    }
    
    deinit {
        loaderTextView.stopRotating()
    }
    
    override func loadView() {
        if let nibView = Bundle.main.loadNibNamed("RotatingCharacterLoaderVC", owner: self, options: nil)?.first as? UIView {
            self.view = nibView
        }
    }
    
    
    
    private func setLayers() {
        loaderTextView.layers = [
                   CircularTextView.Layer(
                       texts: kanjiExtra,
                       radius: 30,
                       rotationSpeed: 0.05,
                       font: UIFont.systemFont(ofSize: 16),
                       textColor: UIColor.red,
                       alpha: 1.0,
                       direction: .clockwise
                   ),
                   CircularTextView.Layer(
                       texts: kanji,
                       radius: 60,
                       rotationSpeed: 0.04,
                       font: UIFont.init(name: Constants.Font.poppins_bold, size: 20)!,
                       textColor: UIColor(hex: "#000100")!,
                       alpha: 0.8,
                       direction: .autoReverse,
                       reverseDuration: 2.0
                   ),
                   CircularTextView.Layer(
                       texts: arabic,
                       radius: 90,
                       rotationSpeed: 0.03,
                       font: UIFont.init(name: Constants.Font.poppins_medium, size: 22)!,
                       textColor: UIColor.gray,
                       alpha: 0.6,
                       direction: .autoReverse,
                       reverseDuration: 2.0
                       
                   ),
                   CircularTextView.Layer(
                       texts: hindi,
                       radius: 120,
                       rotationSpeed: 0.02,
                       font: UIFont.init(name: Constants.Font.poppins_bold, size: 23)!,
                       textColor: UIColor(hex: "#272829")!,
                       alpha: 0.7,
                       direction: .counterclockwise
                       
                   ),
                   
                   CircularTextView.Layer(
                       texts: mixed,
                       radius: 150,
                       rotationSpeed: 0.01,
                       font: UIFont.init(name: Constants.Font.poppins_bold, size: 25)!,
                       textColor: UIColor(hex: "#000100")!,
                       alpha: 8.0,
                       direction: .clockwise
                   )
               ]
    }
    
    private func showChangView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
            
            
        }
        
    }
}
