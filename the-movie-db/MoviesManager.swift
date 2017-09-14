//
//  MoviesManager.swift
//  the-movie-db
//
//  Created by Maxim Belsky on 14/09/2017.
//  Copyright © 2017 Maxim Belsky. All rights reserved.
//

import Foundation

class MoviesManager {

    static let `default` = MoviesManager()

    private init() {}

    func loadMovies(`for` category: Category, `in` presenter: MoviesPresenter) {
        presenter.present([Movie(name: "1"),Movie(name: "2"),Movie(name: "3"),Movie(name: "4")])
    }
}
