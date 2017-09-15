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

    fileprivate let movieCellId = "MovieCell"

    fileprivate var movies = [Movie]() {
        didSet {
            activityIndicator.isHidden = !movies.isEmpty
            cvMovies.isHidden = movies.isEmpty

            cvMovies.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.scrollDirection = .horizontal
        cvMovies.collectionViewLayout = cvLayout
        cvMovies.register(UINib(nibName: "MovieCell", bundle: nil), forCellWithReuseIdentifier: movieCellId)
        cvMovies.showsHorizontalScrollIndicator = false

        cvMovies.dataSource = self
        cvMovies.delegate = self
    }

    func present(_ movies: [Movie]?) {
        if let movies = movies {
            self.movies = movies
        } else {
            self.movies.removeAll()
        }
    }
}

//MARK: - UICollectionViewDataSource
extension CategoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieCellId,
                                                            for: indexPath) as? MovieCell else {
            fatalError()
        }
        cell.movie = movies[indexPath.row]
        return cell
    }
}

extension CategoryCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 230, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}

protocol MoviesPresenter: class {
    func present(_ movies: [Movie]?)
}

extension Hashable where Self: MoviesPresenter {
    var hashValue: Int { return 0 }
}
