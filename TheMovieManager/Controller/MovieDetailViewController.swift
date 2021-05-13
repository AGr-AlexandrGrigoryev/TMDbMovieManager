//
//  MovieDetailViewController.swift
//  TheMovieManager
//
//  Created by Alexandr Grigoryev on 20/11/2020.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var watchlistBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    var movie: Movie!
    
    var isWatchlist: Bool {
        return MovieModel.watchlist.contains(movie)
    }
    
    var isFavorite: Bool {
        return MovieModel.favorites.contains(movie)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = movie.title
        
        toggleBarButton(watchlistBarButtonItem, enabled: isWatchlist)
        toggleBarButton(favoriteBarButtonItem, enabled: isFavorite)
        isNetworkActivity(true)
        TMDBClient.downloadPoster(movie.posterPath ?? "") { [self] (data, error) -> (Void) in
            if let data = data {
                imageView.image = UIImage(data: data)
                isNetworkActivity(false)
            } else {
                print(error as Any)
            }
        }
        
    }
    
    @IBAction func watchlistButtonTapped(_ sender: UIBarButtonItem) {
        print("tapped")
        TMDBClient.addToWatchList(movieId: movie.id, watchList: !isWatchlist) { [self] (success, error) -> (Void) in
            if success {
                print("success")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
                toggleBarButton(watchlistBarButtonItem, enabled: !isWatchlist)
            } else {
                print(error as Any)
            }
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        TMDBClient.addToFavoriteList(movieId: movie.id, watchList: !isFavorite) { [self] (success, error) -> (Void) in
            if success{
                print("success")
                NotificationCenter.default.post(name: NSNotification.Name("reloadFavorites"), object: nil)
                toggleBarButton(favoriteBarButtonItem, enabled: !isFavorite)
            }
        }
    }
    
    func toggleBarButton(_ button: UIBarButtonItem, enabled: Bool) {
        if enabled {
            button.tintColor = UIColor.primaryDark
        } else {
            button.tintColor = UIColor.gray
        }
    }
    
    
}
