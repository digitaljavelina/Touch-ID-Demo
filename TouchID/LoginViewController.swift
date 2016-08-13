//
//  LoginViewController.swift
//  TouchID
//
//  Created by Simon Ng on 24/2/15.
//  Copyright (c) 2015 AppCoda. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {
    @IBOutlet weak var backgroundImageView:UIImageView!
    @IBOutlet weak var loginView:UIView!
    @IBOutlet weak var emailTextField:UITextField!
    @IBOutlet weak var passwordTextField:UITextField!
    
    private var imageSet = ["cloud", "coffee", "food", "pmq", "temple"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Randomly pick an image
        let selectedImageIndex = Int(arc4random_uniform(5))
        
        // Apply blurring effect
        backgroundImageView.image = UIImage(named: imageSet[selectedImageIndex])
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        
        loginView.hidden = true
        
        authenticateWithTouchID()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLoginDialog() {
        // Move the login view off screen
        loginView.hidden = false
        loginView.transform = CGAffineTransformMakeTranslation(0, -700)

        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
            
            self.loginView.transform = CGAffineTransformIdentity
            
            }, completion: nil)
        
    }
    
    // start authentication process
    
    func authenticateWithTouchID() {
        // get the local authentication context
        
        let localAuthContext = LAContext()
        let reasonText = "Authentication is required to sign in to AppCoda"
        var authError: NSError?
        
        if !localAuthContext.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &authError) {
            print(authError?.localizedDescription)
            
            // display the login dialog when TouchID is not available - will need to provide alternate auth method
            
            showLoginDialog()
            
            return
        }
        
        // perform TouchID authentication
        
        localAuthContext.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonText) { (success: Bool, error: NSError?) -> Void in
            if success {
                print("Successfully authenticated")
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    self.performSegueWithIdentifier("showHomeScreen", sender: nil)
                })
            } else {
                if let error = error {
                    switch error.code {
                    case LAError.AuthenticationFailed.rawValue:
                        print("Authentication Failed")
                    case LAError.PasscodeNotSet.rawValue:
                        print("Passcode not set")
                    case LAError.SystemCancel.rawValue:
                        print("Authentication was cancelled by the system")
                    case LAError.UserCancel.rawValue:
                        print("Authentication was cancelled by the user")
                    case LAError.TouchIDNotEnrolled.rawValue:
                        print("Authentication could not start because there are no enrolled fingerprints")
                    case LAError.TouchIDNotAvailable.rawValue:
                        print("Authentication could not start because TouchID is not available")
                    case LAError.UserFallback.rawValue:
                        print("User tapped the fallback button (Enter password).")
                    default:
                        print(error.localizedDescription)
                    }
                    
                    // fallback to password authentication
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.showLoginDialog()
                    })
                }
            }
        }
    }
    
    @IBAction func authenticateWithPassword() {
        if emailTextField.text == "hi@appcoda.com" && passwordTextField.text == "1234" {
            performSegueWithIdentifier("showHomeScreen", sender: nil)
        } else {
            
            // shake screen to indicate incorrect username/password combo
            
            loginView.transform = CGAffineTransformMakeTranslation(45, 0)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: .CurveEaseInOut, animations: {
                    self.loginView.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }

}
