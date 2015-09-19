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
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        getMovies(false)
    }
    
    func getMovies(isRefresh:Bool) {
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=99ekrcc859vkvku6yfj36hdm&limit=25&country=us")!
        let request = NSURLRequest(URL: url)
        
        if !isRefresh {
            // Display a loading state
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                
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
                
                print(json)
            } catch let error as NSError {
                print("Failed to load: \(error.description)")
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!

        let movie = movies![indexPath.row]

        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsController

        movieDetailsViewController.movie = movie
    }
}
