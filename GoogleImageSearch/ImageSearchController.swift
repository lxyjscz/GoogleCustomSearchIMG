import UIKit
import Foundation

let reuseIdentifier = "ImageCell"
let scaleConstant : CGFloat = 0.67

public class ImageSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    var searchResults = [GoogleImage]()
    public var google = GoogleImageSearcher()
    var fetching = false
    var currentPage = 0
    var currentSearchTerm : String?
    public var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var lock = NSLock()

    @IBOutlet public weak var searchField: UITextField!

    override public func viewDidLoad() {
        activityIndicator.hidesWhenStopped = true
        searchField.addSubview(activityIndicator)
        activityIndicator.frame = searchField.bounds
    }
    
    
    func loadDataFromGoogle(){
        google.searchForTerm(currentSearchTerm!, page: currentPage) {
            results, error in
            self.activityIndicator.stopAnimating()
            
            if let error = error {
                let errorUI = UIAlertController(title: "Error", message: error.description, preferredStyle: .Alert)
                errorUI.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                self.presentViewController(errorUI, animated: true, completion: nil)
            }
            
            if let results = results where results.count > 0 {
                self.searchResults += results
                self.fetching = false
                
                var indexPaths = [NSIndexPath]()
                for i in (self.currentPage*10)..<(self.currentPage*10)+10 {
                    indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
                }

                self.collectionView?.insertItemsAtIndexPaths(indexPaths)
                self.currentPage++
                if self.currentPage < 3 {
                    self.loadDataFromGoogle()
                }
            }
        }
    }
    

    override public func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > contentHeight - scrollView.frame.size.height {
            if !self.fetching && self.currentSearchTerm != nil && self.currentPage < 8 {
                self.fetching = true
                loadDataFromGoogle()
            }
        }
    }

    // MARK: UITextFieldDelegate
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        lock.lock()
        currentSearchTerm = textField.text
        searchResults = [GoogleImage]()
        collectionView?.reloadData()
        currentPage = 0
        activityIndicator.startAnimating()
        loadDataFromGoogle()
        textField.resignFirstResponder()
        lock.unlock()
        return true
    }

    // MARK: UICollectionViewDataSource
    override public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }

    override public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ImageCell
        cell.imageView.image = searchResults[indexPath.row].thumbnail
        return cell
    }

    // MARK: UICollectionViewDelegateFlowLayout
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if var size = searchResults[indexPath.row].thumbnail?.size {
            size.height = size.height * scaleConstant
            size.width = size.width * scaleConstant
            return size
        }
        return CGSize(width: 100, height: 100)
    }
    
    
    
    @IBAction func typing(sender: UITextField) {
        if sender.text!.characters.count>=1{
            lock.lock()
            currentSearchTerm = sender.text
            searchResults = [GoogleImage]()
            collectionView?.reloadData()
            currentPage = 0
            activityIndicator.startAnimating()
            loadDataFromGoogle()
            lock.unlock()
        }
        
    }
    
}
