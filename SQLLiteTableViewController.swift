//
//  SQLLiteTableViewController.swift
//  swTest2
//
//  Created by Pratyush on 2/6/18.
//  Copyright © 2018 Pratyush. All rights reserved.
//

import UIKit
import SQLite3
import Kingfisher

class SQLLiteTableViewController: UITableViewController {
    var db: OpaquePointer?
    var brandList = [Brand]()
    var cocktailList = [Cocktail]()
    var c_name: String?
    var selImage: UIImage?
    let placeH: UIImage = UIImage(named: "Group 1656")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileURL = Bundle.main.url(forResource: "CocktailsDB", withExtension: ".sqlite")
        if sqlite3_open(fileURL!.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        else {
            print("Opened database!")
        }
        //readBrands()
        readCocktails()
        //sqlite3_close(db)
    }
    
    func readCocktails() {
        cocktailList.removeAll()
        let queryString = "SELECT id,name FROM COCKTAIL"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            
            cocktailList.append(Cocktail(id: Int(id), name: String(name)))
        }
        self.tableView.reloadData()
    }
    
    func readBrands() {
        brandList.removeAll()
        let queryString = "SELECT id,name FROM BRANDS"
        var stmt: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW) {
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            
            brandList.append(Brand(id: Int(id), name: String(name)))
        }
        self.tableView.reloadData()
    }
    
//    func getImage(index: Int) -> String {
//        let queryString = "SELECT i.name FROM images i JOIN cocktail c ON c.image_id = i.id WHERE c.id = \(index)"
//        var stmt: OpaquePointer?
//        var imgName: String = "Failed"
//        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
//            let errmsg = String(cString: sqlite3_errmsg(db)!)
//            print("error preparing insert: \(errmsg)")
//        }
//
//        if sqlite3_step(stmt) == SQLITE_ROW {
//            imgName = String(cString: sqlite3_column_text(stmt, 0))
//        }
//        return imgName
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cocktailList.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cocktail: Cocktail
        cocktail = cocktailList[indexPath.row]
        cell.textLabel?.text = cocktail.name
//        let imgName = getImage(index: indexPath.row)
        let queryString = "SELECT i.name FROM images i JOIN cocktail c ON c.image_id = i.id WHERE c.id = \(indexPath.row + 1)"
        var stmt: OpaquePointer?
        var imgName: String = "default_image"
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        if sqlite3_step(stmt) == SQLITE_ROW {
            imgName = String(cString: sqlite3_column_text(stmt, 0))
        }
        if imgName == "default_image" {
            print("Query/kf problem.")
        }
        let url = URL(string: "https://barsys.biz/img/\(imgName).jpg")
        cell.imageView?.kf.setImage(with: url, placeholder: placeH)
        //cell.setNeedsLayout()
        //tableView.reloadData()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
            c_name = cocktailList[indexPath.row].name
        
        //selImage =
        //performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
//    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.imageView!.kf.cancelDownloadTask()
//    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailSegue" {
            let vc = segue.destination as! detailViewController
            let index = tableView.indexPathForSelectedRow?.row
            vc.c_name = cocktailList[index!].name
        }
    }
 

}

extension SQLLiteTableViewController:UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap {
            URL(string: "https://barsys.biz/img/\(cocktailList[$0.row + 1]).jpg")
        }
        
        ImagePrefetcher(urls: urls).start()
    }
}
