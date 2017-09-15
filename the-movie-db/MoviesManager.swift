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

    fileprivate static let discoverMovieUrl = "https://api.themoviedb.org/3/discover/movie"
    fileprivate static let apiKey = "74a514887c48a995d28c5a4352a6d18a"

    private var movies = [Category: [Movie]]()

    private init() {}

    func loadMovies(`for` category: Category, `in` presenter: MoviesPresenter) {
        presentMovies(for: category, in: presenter)

        guard let url = buildUrl(for: category) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                    let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
                    let results = json["results"] as? [[String: Any]]
            else {
                return
            }

            let movies = results.map { Movie(jsonDict: $0) }.filter { $0 != nil } as! [Movie]
            DispatchQueue.main.async {
                self.movies[category] = movies
                self.presentMovies(for: category, in: presenter)
            }
        }.resume()
    }

    private func buildUrl(`for` category: Category) -> URL? {
        var urlComponents = URLComponents(string: MoviesManager.discoverMovieUrl)
        urlComponents?.queryItems = [URLQueryItem(name: "api_key", value: MoviesManager.apiKey)]

        switch category {
        case .new:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            urlComponents?.queryItems?.append(URLQueryItem(name: "sort_by", value: "primary_release_date.desc"))

            let today = dateFormatter.string(from: Date())
            let thirtyDaysInSeconds: TimeInterval = 60 * 60 * 24 * 30
            let thirtyDaysAgo = dateFormatter.string(from: Date(timeIntervalSinceNow: -thirtyDaysInSeconds))

            urlComponents?.queryItems?.append(URLQueryItem(name: "primary_release_date.gte", value: thirtyDaysAgo))
            urlComponents?.queryItems?.append(URLQueryItem(name: "primary_release_date.lte", value: today))
        case .popular:
            urlComponents?.queryItems?.append(URLQueryItem(name: "sort_by", value: "popularity.desc"))
            urlComponents?.queryItems?.append(URLQueryItem(name: "page", value: "1"))
        case .highest:
            urlComponents?.queryItems?.append(URLQueryItem(name: "sort_by", value: "vote_average.desc"))
            urlComponents?.queryItems?.append(URLQueryItem(name: "page", value: "1"))
            urlComponents?.queryItems?.append(URLQueryItem(name: "vote_count.gte", value: "500"))

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: Date())
            urlComponents?.queryItems?.append(URLQueryItem(name: "primary_release_year", value: year))
        }

        return urlComponents?.url
    }

    private func presentMovies(`for` category: Category, `in` presenter: MoviesPresenter) {
        let movies = self.movies[category]
        presenter.present(movies)
    }
}
