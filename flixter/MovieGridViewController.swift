//
//  MovieGridViewController.swift
//  flixter
//
//  Created by Jesse Pantoja on 2/26/21.
//

import UIKit
import AlamofireImage

class MovieGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var movies = [[String:Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // If we want to configure and customize our grid layout, we have to use this layout
        // object
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        
        // minimumLineSpacing controls space in between the rows. Value is in px
        layout.minimumLineSpacing = 10
        // minimumInteritemSpacing
        layout.minimumInteritemSpacing = 0
        
        // view.frame.size.width allows us to access the width of the phone being used
        let width = (view.frame.size.width - layout.minimumInteritemSpacing * 2) / 3
        layout.itemSize = CGSize(width: width, height: width * 1.5)
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/297762/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
              let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            self.movies = dataDictionary["results"] as! [[String:Any]]
            
            
            // Recall how often are functions below called: just at startup
            // At startup, the app is in the process of fetching data, so return movies.count line in first function below will be 0 so nothing will be shown in collection view
            // After we get the data we can call collectionView.reloadData() because at this point movies will have data. 
            self.collectionView.reloadData()
           }
        }
        task.resume()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieGridCell", for: indexPath) as! MovieGridCell
        
        let movie = movies[indexPath.item]
        
        let baseURL = "https://image.tmdb.org/t/p/w185"
        let posterPath = movie["poster_path"] as! String
        let posterURL = URL(string: baseURL + posterPath)!
        
        cell.posterView.af_setImage(withURL: posterURL)
        
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)!
        let movie = movies[indexPath.item]
        
        // Pass the selected object to the new view controller.
        // Must cast the destination to a MovieDetailsViewController otherwise you get a
        // generic UIViewController
        let superheroMovieDetailsViewController = segue.destination as! SuperheroMovieDetailsViewController
        
        // Now that we've casted in MovieDetailsViewController, set .movie data member
        // as the movie that was tapped on, effectively passing movie into the
        // MovieDetailsViewController
        superheroMovieDetailsViewController.movie = movie
        
        // Deselects the cell that was selected upon coming back to the UITableView
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    

}
