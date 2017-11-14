//
//  LoginViewController.swift
//  Skimddit
//
//  Created by Riyazh Dholakia on 10/24/17.
//  Copyright © 2017 Riyazh. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBAction func onLoginPressed(_ sender: UIButton) {
        UIApplication.shared.open(oauth!)
    }
    
    @IBAction func onSkipPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
