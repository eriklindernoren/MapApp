//
//  PhotoGallery.swift
//  MapApp
//
//  Created by Erik Linder-Norén on 2014-12-28.
//  Copyright (c) 2014 Mina Appar. All rights reserved.
//

import UIKit


class PhotoGallery: UICollectionViewController{

    @IBOutlet var photoCollection: UICollectionView!
    
    var photoCache = Dictionary<Int, UIImage>()
    var photos = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRec = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe"))
        gestureRec.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(gestureRec)
    }

    func handleSwipe(){
        photoCache = Dictionary<Int,UIImage>()
        photos = NSMutableArray()
        let newVC = LocationVC()
        let vcs = NSMutableArray(array: self.navigationController!.viewControllers)
        vcs.insertObject(newVC, atIndex: vcs.count-1)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.collectionView?.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as ImageCell
        
        if photoCache[indexPath.item] != nil{
            cell.imageView.image = photoCache[indexPath.item]
        }else{
            cell.imageView.image = UIImage()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                var index = indexPath.item
                var error:NSError?
                let urlstring = self.photos.objectAtIndex(indexPath.item) as NSString
                if let url = NSURL(string: urlstring){
                    let data = NSData(contentsOfURL: url, options: nil, error: &error)
                    if error == nil{
                        let image = UIImage(data: data!)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.imageView.image = image
                            self.photoCache[index] = image
                        })
                    }
                }
                
            })
        }
        return cell
    }
}
