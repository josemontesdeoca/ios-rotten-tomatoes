//
//  MovieDetailsController.swift
//  RottenTomatoes
//
//  Created by Jose Montes de Oca on 9/17/15.
//  Copyright © 2015 JoseOnline. All rights reserved.
//

import UIKit

class MovieDetailsController: UIViewController {
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        
        let posterUrl = movie.valueForKeyPath("posters.original") as! String
        
        var placeholderImage: UIImageView = UIImageView()
        placeholderImage.setImageWithURL(NSURL(string: posterUrl)!)
        
        var posterOriginalUrl = ""
        
        // Hack to get around not having full size images
        let range = posterUrl.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        
        if let range = range {
            posterOriginalUrl = posterUrl.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        posterImage.setImageWithURL(NSURL(string: posterOriginalUrl)!, placeholderImage: placeholderImage.image)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
