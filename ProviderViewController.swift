//
//  ProviderViewController.swift
//  swTest2
//
//  Created by Pratyush on 2/2/18.
//  Copyright © 2018 Pratyush. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import FirebaseAuth

class ProviderViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    @IBOutlet weak var gLogin: UIButton!
    @IBOutlet weak var fLogin: UIButton!
    var currentUser: User?
    //var tokenID: String?
    @IBAction func gLoginPressed(_ sender: UIButton) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    
    @IBAction func fLoginPressed(_ sender: UIButton) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                    Auth.auth().signIn(with: credential) { (user, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        self.currentUser = Auth.auth().currentUser
                        self.currentUser?.getIDToken(completion: { (idToken, error) in
                            if error != nil {
                                print(idToken!)
                                self.getFBUserData()
                                return
                            }
                            //print(error!)
                        })
                        
                    }
                }
            }
        }
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    print(result!)
                    self.currentUser = Auth.auth().currentUser
                    self.currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                        if let error = error {
                            print(error)
                            return;
                        }
                        //self.tokenID = idToken
                        if let dict = result as? [String: Any] {
                            if let name = dict["name"] as? String {
                                print(idToken!)
                                self.tokenToJson(tokenID: idToken!, name: name)
                            }
                        }
                    }
                    //self.getIDToken()
                    
                }
                else {
                    print(error!)
                }
            })
        }
        
    }
    
    func getIDToken() {
        currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error {
                print(error)
                return;
            }
            //self.tokenID = idToken
        }
    }
    
    func tokenToJson(tokenID: String, name: String) {
        let json: [String: Any] = ["name": name,
                                   "phone": "8884119197",
                                   "gender": "M",
                                   "dob": "11/08/1996"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let url = URL(string: "https://barsyseliten.appspot.com/users/details?idToken=\(tokenID)")!  //TODO: pass tokenID as parameter
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //request.addValue("1815547515124350", forHTTPHeaderField: "idToken")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response!)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString!)")
        }
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
//    func signIn(_ signIn: GIDSignIn!,
//                dismiss viewController: UIViewController!) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
//            print(user)
            // ...
        } else {
            print("\(error)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
