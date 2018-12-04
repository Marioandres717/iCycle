//
//  RoutePictureCollectionViewController.swift
//  iCycle
//
//  Created by Mario Rendon Zapata on 2018-12-03.
//  Copyright © 2018 Valentyna Akulova. All rights reserved.
//

import UIKit

class RoutePictureCollectionViewController: UICollectionViewController {
    
    var photos: [RoutePhoto] = []
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! routePhotoCollectionViewCell
        
        let photo = photos[indexPath.item]
        cell.routeImage.image = photo.photoImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
