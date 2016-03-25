import UIKit

public class GoogleImageSearcher {
    var searchResults = [GoogleImage]()
    
    public func searchForTerm(term:String, page:Int, completion:(results:[GoogleImage]?, error:NSError?)->Void){
        let escapedTerm = term.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        //        let URLString = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=\(escapedTerm)&rsz=8&start=\(page*8)"
//        let URLString = "https://www.googleapis.com/customsearch/v1?q=\(escapedTerm)&rsz=8&searchType=image&key=AIzaSyCKm0mQD7Fy6fPKi5mXrbeVcPTsxlgp6A4&cx=001535763251306365112:juu9xl-ev4i&alt=json"
        
        let URLString = "https://www.googleapis.com/customsearch/v1?q=\(escapedTerm)&startIndex=\(page*10+1)&rsz=8&searchType=image&key=AIzaSyCil70tTA2XTEDrmZsNEie_jJwDXlSs5wI&cx=002685961158933403709:8lxm04xihl4&alt=json"
        
        let searchURL = NSURL(string: URLString)!
        
        NSURLSession.sharedSession().dataTaskWithURL(searchURL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completion(results: nil, error: error)
                return
            }
            do{
                if let resultsDictionary:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions(rawValue: 0)) as? NSDictionary{
                    
                    //                    let responeData = resultsDictionary["items"] as! NSDictionary
                    //                    let photoResults = responeData["request"] as! [NSDictionary]
                    
                    let responeData = resultsDictionary["items"] as! NSArray
                    let photoResults = responeData as! [NSDictionary]
                    
                    let googlePhotos : [GoogleImage] = photoResults.map {
                        photoDictionary in
                        
                        let thumbNailURL = photoDictionary["image"] as! NSDictionary
                        let ddd = thumbNailURL["thumbnailLink"] as!String
                        let googleImage = GoogleImage()
                        let imageData = NSData(contentsOfURL: NSURL(string: ddd)!)
                        googleImage.thumbnail = UIImage(data: imageData!)
                        
                        return googleImage
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        completion(results:googlePhotos, error: nil)
                    })
                }
            }
            catch{
                return
            }
        }).resume()
        
    }

    
    
}
