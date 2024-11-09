//
//  SafariHelper.swift
//  j-lingo
//
//  Created by as on 8/7/24.
//

import UIKit
import SafariServices

final class SafariHelper {
    
    static func openURL(_ urlString: String, from viewController: UIViewController) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        viewController.present(safariVC, animated: true, completion: nil)
    }
}

