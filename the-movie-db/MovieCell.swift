//
//  MovieCell.swift
//  the-movie-db
//
//  Created by Maxim Belsky on 14/09/2017.
//  Copyright © 2017 Maxim Belsky. All rights reserved.
//

import UIKit

class MovieCell: UICollectionViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    var movie: Movie! {
        didSet {
            lblName.text = movie.name
            MoviesManager.default.loadPoster(in: imageView, for: movie)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
    }
}
