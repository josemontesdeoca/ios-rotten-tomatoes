//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Jose Montes de Oca on 9/16/15.
//  Copyright © 2015 JoseOnline. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    
    let apiUrls = [
        "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=99ekrcc859vkvku6yfj36hdm&limit=25&country=us",
        "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/new_releases.json?apikey=99ekrcc859vkvku6yfj36hdm&limit=25&country=us"
    ]
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var tabIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide error bar
        self.errorView.hidden = true
        
        // setup pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tabIndex = self.tabBarController!.selectedIndex
        
        getMovies(false)
    }
    
    func getMovies(isRefresh:Bool) {
        if !isRefresh {
            // Display a loading state
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        let request = NSURLRequest(URL: NSURL(string: apiUrls[tabIndex])!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let d = data {
                let json = try! NSJSONSerialization.JSONObjectWithData(d, options: []) as? NSDictionary
                
                // Check if valid json
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                    
                    if isRefresh {
                        self.refreshControl.endRefreshing()
                    } else {
                        // Remove loading state
                        MBProgressHUD.hideHUDForView(self.view, animated: true)
                    }
                    
                }
            } else {
                if let e = error {
                    print("Failed to load: \(e)")
                }
                
                self.errorView.hidden = false
                
                if isRefresh {
                    self.refreshControl.endRefreshing()
                }
                
                self.delay(2, closure: {
                    self.errorView.hidden = true
                })
            }
        }

    }
    
    func onRefresh() {
        getMovies(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

        let movie = movies![indexPath.row]

        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!

        cell.posterView.setImageWithURL(posterUrl)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!

        let movie = movies![indexPath.row]

        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsController

        movieDetailsViewController.movie = movie
        movieDetailsViewController.hidesBottomBarWhenPushed = true
    }
}
