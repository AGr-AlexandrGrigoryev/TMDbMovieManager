//
//  WatchlistViewController.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//

import UIKit

class WatchlistViewController: UIViewController {
    
    let ai = UIActivityIndicatorView(style: .medium)
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.update), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        TMDBClient.getWatchlist() { movies, error in
            MovieModel.watchlist = movies
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        //another option is download and reload data from TMDB user come to Watchlist view controller.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.movie = MovieModel.watchlist[selectedIndex]
        }
    }
    
    //For update data from notification center
    @objc func update() {
        TMDBClient.getWatchlist() { movies, error in
            MovieModel.watchlist = movies
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}

extension WatchlistViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieModel.watchlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell")!
        
        let movie = MovieModel.watchlist[indexPath.row]
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MovieTableViewCell")
        cell.textLabel?.text = movie.title
        cell.textLabel?.font = .boldSystemFont(ofSize: 14)
        cell.detailTextLabel?.numberOfLines = 4
        cell.detailTextLabel?.text = movie.overview
    
        if let moviePoster = movie.posterPath {
            
            TMDBClient.downloadPoster(moviePoster) {  (data, error) -> (Void) in
                guard let data = data else {
                    return
                }
                cell.imageView?.image = UIImage(data: data )
                
                cell.setNeedsLayout()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
