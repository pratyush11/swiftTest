//
//  LoggedViewController.swift
//  swTest2
//
//  Created by Pratyush on 2/1/18.
//  Copyright © 2018 Pratyush. All rights reserved.
//

import UIKit

class LoggedViewController: UIViewController {

    var uid: String!
    var email: String!
    //var photoURL: URL!
    @IBOutlet weak var uidLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uidLabel.text = uid
        emailLabel.text = email
//        DispatchQueue.global().async {
//            let data = try? Data(contentsOf: self.photoURL!)
//            DispatchQueue.main.async {
//                self.imageView.image = UIImage(data: data!)
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
