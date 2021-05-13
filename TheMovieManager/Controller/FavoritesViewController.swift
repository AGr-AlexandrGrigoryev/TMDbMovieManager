//
//  FavoritesViewController.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: NSNotification.Name("reloadFavorites"), object: nil)
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func loadData() {
        TMDBClient.getFavoriteMovies { [self] (movie, error) -> (Void) in
            guard error != nil else {
                MovieModel.favorites = movie
                tableView.reloadData()
                return
            }
        }
    }
    
    @objc func update() {
        loadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! MovieDetailViewController
            detailVC.movie = MovieModel.favorites[selectedIndex]
        }
    }
    
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MovieModel.favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell")!
        
        let movie = MovieModel.favorites[indexPath.row]
        
        cell.textLabel?.text = movie.title
        
        if let moviePoster = movie.posterPath {
            TMDBClient.downloadPoster(moviePoster) { (data, error) -> (Void) in
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
