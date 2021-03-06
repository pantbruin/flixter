//
//  MoviesViewController.swift
//  flixter
//
//  Created by Jesse Pantoja on 2/18/21.
//

import UIKit
import AlamofireImage

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
              let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            self.movies = dataDictionary["results"] as! [[String:Any]]
            
            // At this point the DL from the API is complete
            // We have to have the tableView to reload its data to populate the content
            self.tableView.reloadData()
              // TODO: Get the array of movies
              // TODO: Store the movies in a property to use elsewhere
              // TODO: Reload your table view data
           }
        }
        task.resume()


    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String
        let synopsis = movie["overview"] as! String
        
        
        cell.titleLabel.text = title
        cell.synopsisLabel.text = synopsis
        
        let baseURL = "https://image.tmdb.org/t/p/w185"
        let posterPath = movie["poster_path"] as! String
        let posterURL = URL(string: baseURL + posterPath)!
        
        cell.posterView.af_setImage(withURL: posterURL)
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // prepare will 'prepare' whatever is needed before going into MovieDetailsViewController, including passing it the movie that was selected from the MoviesViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Find the selected movie cell and assign the cell based on what was tapped on. This is stored in the sender argument
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let movie = movies[indexPath.row]
        
        // Pass the selected object to the new view controller.
        // Must cast the destination to a MovieDetailsViewController otherwise you get a
        // generic UIViewController
        let detailsViewController = segue.destination as! MovieDetailsViewController
        
        // Now that we've casted in MovieDetailsViewController, set .movie data member
        // as the movie that was tapped on, effectively passing movie into the
        // MovieDetailsViewController
        detailsViewController.movie = movie
        
        // Deselects the cell that was selected upon coming back to the UITableView
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

}
