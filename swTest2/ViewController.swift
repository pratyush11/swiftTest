//
//  ViewController.swift
//  swTest2
//
//  Created by Ghazalah on 1/23/18.
//  Copyright © 2018 Pratyush. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    var uid: String!
    var email: String!
    var photoURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubview(toFront: self.loginButton)
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                //self.performSegue(withIdentifier: self.loginToList, sender: nil)
                user?.getIDToken(completion: nil)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginAction(_ sender: Any) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                
                if error == nil {
                    print("You have successfully logged in")
                    let token = InstanceID.instanceID().token()
                    print(token!)
                    let user = Auth.auth().currentUser
                    self.uid = user!.uid
                    self.email = user!.email
                    //self.photoURL = user!.photoURL
//                    if let user = user {
//                        // The user's ID, unique to the Firebase project.
//                        // Do NOT use this value to authenticate with your backend server,
//                        // if you have one. Use getTokenWithCompletion:completion: instead.
//                        self.uid = user.uid
//                        self.email = user.email
//                        //self.photoURL = user.photoURL
//                    }
                    //Go to the HomeViewController if the login is sucessful
                    
                    self.performSegue(withIdentifier: "loginSuccess", sender: self)
                   
                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSuccess" {
            let vc: LoggedViewController = segue.destination as! LoggedViewController
            vc.uid = uid
            vc.email = email
            //vc.photoURL = photoURL
        }
    }
    
}
