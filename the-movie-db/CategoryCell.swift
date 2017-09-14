//
//  CategoryCell.swift
//  the-movie-db
//
//  Created by Maxim Belsky on 14/09/2017.
//  Copyright © 2017 Maxim Belsky. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell, MoviesPresenter {

    @IBOutlet weak var cvMovies: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var movies: [Movie]? {
        didSet {
            let hasMovies = nil != movies
            activityIndicator.isHidden = hasMovies
            cvMovies.isHidden = !hasMovies
        }
    }

    func present(_ movies: [Movie]?) {
        self.movies = movies
    }
}

protocol MoviesPresenter: class {
    func present(_ movies: [Movie]?)
}
