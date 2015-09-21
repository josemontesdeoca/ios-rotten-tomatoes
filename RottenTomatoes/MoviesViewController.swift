//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Jose Montes de Oca on 9/16/15.
//  Copyright © 2015 JoseOnline. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let apiUrls = [
        "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=99ekrcc859vkvku6yfj36hdm&limit=25&country=us",
        "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/new_releases.json?apikey=99ekrcc859vkvku6yfj36hdm&limit=25&country=us"
    ]
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var refreshControlGrid: UIRefreshControl!
    var tabIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide error bar
        self.errorView.hidden = true
        
        // setup pull to refresh
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        refreshControlGrid = UIRefreshControl()
        refreshControlGrid.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(refreshControlGrid)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        
        searchBar.delegate = self
        
        tabIndex = self.tabBarController!.selectedIndex
        
        getMovies(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        nav?.tintColor = UIColor.whiteColor()
        nav?.backgroundColor = UIColor.greenColor()
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.yellowColor()]
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
                    self.filteredMovies = self.movies
                    
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    
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
                    self.refreshControlGrid.endRefreshing()
                } else {
                    // Remove loading state
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
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
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell

        let movie = filteredMovies![indexPath.row]

        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!

        cell.posterView.setImageWithURL(posterUrl)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.view.endEditing(true)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = filteredMovies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieGridCell", forIndexPath: indexPath) as! MovieGridCell
        
        let movie = filteredMovies![indexPath.row]
        
        cell.titleLabel.text = movie["title"] as? String
        
        let posterUrl = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        
        cell.posterImage.setImageWithURL(posterUrl)
        
        return cell
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies?.filter({ (movie: NSDictionary) -> Bool in
            let movieTitle:String = movie["title"] as! String
            let isAMatch = movieTitle.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            return isAMatch
        })
        
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    @IBAction func onSegmentValueChanged(sender: AnyObject) {
        print("Segmented Control Index: \(segmentedControl.selectedSegmentIndex)")
        
        if segmentedControl.selectedSegmentIndex == 1 {
            tableView.hidden = true
            collectionView.hidden = false
        } else {
            tableView.hidden = false
            collectionView.hidden = true
        }
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var movie: NSDictionary!
        
        if segue.identifier == "MovieSegue" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            
            movie = filteredMovies![indexPath.row]
        } else {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPathForCell(cell)!
            
            movie = filteredMovies![indexPath.row]
        }

        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsController

        movieDetailsViewController.movie = movie
        movieDetailsViewController.hidesBottomBarWhenPushed = true
    }
}
