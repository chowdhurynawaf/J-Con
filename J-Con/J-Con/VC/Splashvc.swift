import UIKit

final class SplashVC: UIViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
       // startAnimation()
        self.moveToVC()
    }
    
    
    func startAnimation() {
        // Initially, set all images to their initial state
        imageView1.alpha = 1.0
        imageView2.alpha = 0.0 // Start with imageView2 and imageView3 hidden
        imageView3.alpha = 0.0
        
        imageView1.transform = .identity
        imageView2.transform = .identity
        imageView3.transform = .identity
        
        // Position imageView1 at the center
        imageView1.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
        
        // Start with only imageView1 visible
        UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseInOut], animations: {
            // After 2 seconds, animate imageView2 and imageView3 to appear
            self.imageView2.alpha = 1.0
            self.imageView3.alpha = 1.0
            
            // Position the images slightly off-center to simulate "many"
            self.imageView1.center = CGPoint(x: self.view.frame.width / 2 - 50, y: self.view.frame.height / 2)
            self.imageView2.center = CGPoint(x: self.view.frame.width / 2 + 50, y: self.view.frame.height / 2)
            self.imageView3.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 + 50)
            
        }, completion: { _ in
            // After the "many" effect, wait for 2 seconds before swapping the images
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.swapImages()
            }
        })
    }
    
    func swapImages() {
        // Animate imageView2 and imageView3 to swap positions
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut], animations: {
            // Swap the positions of imageView2 and imageView3
            let tempCenter = self.imageView2.center
            self.imageView2.center = self.imageView3.center
            self.imageView3.center = tempCenter
        }, completion: { _ in
            // After the swap is complete, start the final merging animation
            self.mergeToOneImage()
        })
    }
    
    func moveToVC() {
        
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func mergeToOneImage() {
        // Animate images back to the center and fade them to one image
        UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseInOut], animations: {
            // All images should now return to the center
            self.imageView1.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            self.imageView2.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            self.imageView3.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            
            // Fade imageView2 and imageView3 out
            self.imageView2.alpha = 0.0
            self.imageView3.alpha = 0.0
        }, completion: { _ in
            // After the final animation completes, make imageView2 and imageView3 hidden
            self.imageView2.isHidden = true
            self.imageView3.isHidden = true
            
            // Optional: You can add a final animation to zoom imageView1 if you like
            UIView.animate(withDuration: 1.0, animations: {
                self.imageView1.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // Optional zoom effect
               
            
            }) { _ in
                self.pushWithData(ofType: HomeVC.self, storyboardName: "Main", animated: true) { _ in
                    
                }
            }
        })
        
       
    }
}
