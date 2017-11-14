//
//  RootViewNavigationController.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/24/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import UIKit

let loginNotificationCenterName = Notification.Name("LogMeInDidCompleteNotification")

class RootNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: loginNotificationCenterName, object: nil, queue: .main) { (_) in
            if let loginVC = self.presentedViewController as? LoginViewController {
                loginVC.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasShownLoginOnce == false {
            let loginVC = storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
            present(loginVC, animated: animated, completion: nil)
            //or delete the completion it is unrequired
            hasShownLoginOnce = true
        }
    }
    
    var hasShownLoginOnce: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "Login")
        } set {
            UserDefaults.standard.set(newValue, forKey: "Login")
            
        }
    }
}

