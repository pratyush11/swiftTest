//
//  CollectionViewController.swift
//  GoogleToolboxForMac
//
//  Created by Pratyush on 2/13/18.
//

import UIKit
import SQLite3
import Kingfisher

private let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {
    var db: OpaquePointer?
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
        readCocktails()
        
        self.collectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        self.collectionView?.reloadData()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "detailsSegue" {
            let vc = segue.destination as! detailViewController
            //let index = collectionView?.indexPathsForSelectedItems?
            //vc.c_name = cocktailList[index!].name
            vc.c_name = self.c_name
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cocktailList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        let cocktail: Cocktail
        cocktail = cocktailList[indexPath.row]
        cell.cocktailName.text = cocktail.name
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
        
        cell.imageView.kf.setImage(with: url, placeholder: placeH)
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        c_name = cocktailList[indexPath.row].name
    }
}

extension CollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.flatMap {
            URL(string: "https://barsys.biz/img/\(cocktailList[$0.row + 1]).jpg")
        }
        
        ImagePrefetcher(urls: urls).start()
    }
}
