//
//  detailViewController.swift
//  swTest2
//
//  Created by Pratyush on 2/7/18.
//  Copyright © 2018 Pratyush. All rights reserved.
//

import UIKit
import SQLite3

class detailViewController: UIViewController {
    var c_name: String?
    var db: OpaquePointer?
    @IBOutlet weak var ingLabel: UILabel!
    @IBOutlet weak var addonLabel: UILabel!
    @IBOutlet weak var garnishLabel: UILabel!
    @IBOutlet weak var glassLabel: UILabel!
    @IBOutlet weak var cocktailImage: UIImageView!
    var ingredients: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileURL = Bundle.main.url(forResource: "CocktailsDB", withExtension: ".sqlite")
        if sqlite3_open(fileURL!.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        else {
            print("Opened database!")
        }
        print(c_name!)
        readIngredients()
        readDetails()
        readImage()
        //TODO: Set image and cocktail name title
        //sqlite3_close(db)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readIngredients() {
        let queryString = "SELECT i1.name,i2.name,i3.name,i4.name,i5.name,i6.name,i7.name,i8.name,i9.name,i10.name,i11.name,i12.name,i13.name,i14.name, c.QNT_1, c.QNT_2, c.QNT_3, c.QNT_4, c.QNT_5, c.QNT_6, c.QNT_7, c.QNT_8, c.QNT_9, c.QNT_10, c.QNT_11, c.QNT_12, c.QNT_13, c.QNT_14 FROM cocktail c JOIN ingredients i1 ON c.ING_1 = i1.id JOIN ingredients i2 ON c.ING_2 = i2.id JOIN ingredients i3 ON c.ING_3 = i3.id JOIN ingredients i4 ON c.ING_4 = i4.id JOIN ingredients i5 ON c.ING_5 = i5.id JOIN ingredients i6 ON c.ING_6 = i6.id JOIN ingredients i7 ON c.ING_7 = i7.id JOIN ingredients i8 ON c.ING_8 = i8.id JOIN ingredients i9 ON c.ING_9 = i9.id JOIN ingredients i10 ON c.ING_10 = i10.id JOIN ingredients i11 ON c.ING_11 = i11.id JOIN ingredients i12 ON c.ING_12 = i12.id JOIN ingredients i13 ON c.ING_13 = i13.id JOIN ingredients i14 ON c.ING_14 = i14.id WHERE c.name = \"\(c_name!)\""
        var stmt: OpaquePointer?
        ingredients = " "
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error in querying ingredients: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            for index in 0...13 {
                
                ingredients = ingredients! + String(cString: sqlite3_column_text(stmt, Int32(index)))
                ingredients = ingredients! + String(cString: sqlite3_column_text(stmt, Int32(index + 14)))
            }
        }
        print(ingredients!)
        self.ingLabel.text = ingredients!
    }
    
    func readDetails() {
        let queryString = "SELECT add_on, garnish, glass FROM cocktail c WHERE c.name=\"\(c_name!)\""
        //print(queryString)
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error in querying details: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let addon = String(cString: sqlite3_column_text(stmt, 0))
            let garnish = String(cString: sqlite3_column_text(stmt, 1))
            let glass = String(cString: sqlite3_column_text(stmt, 2))
            self.addonLabel.text = addon
            self.garnishLabel.text = garnish
            if glass == "0" {
                self.glassLabel.text = "Any"
            }
        }
    }
    
    func readImage() {
        let queryString = "SELECT i.name FROM images i JOIN cocktail c ON c.image_id = i.id WHERE c.name = \"\(c_name!)\""
        var stmt: OpaquePointer?
        var imgName: String = "default_image"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        if sqlite3_step(stmt) == SQLITE_ROW {
            imgName = String(cString: sqlite3_column_text(stmt, 0))
            print(imgName)
        }
        if imgName == "default_image" {
            print("Query/kf problem.")
        }
        let url = URL(string: "https://barsys.biz/img/\(imgName).jpg")
        cocktailImage.kf.setImage(with: url)
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
