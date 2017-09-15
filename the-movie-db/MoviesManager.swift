//
//  MoviesManager.swift
//  the-movie-db
//
//  Created by Maxim Belsky on 14/09/2017.
//  Copyright © 2017 Maxim Belsky. All rights reserved.
//

import UIKit

class MoviesManager {

    static let `default` = MoviesManager()

    fileprivate static let apiKey = "74a514887c48a995d28c5a4352a6d18a"
    fileprivate static let baseUrl = "https://api.themoviedb.org/3/"
    fileprivate static let configurationUrl = MoviesManager.baseUrl + "configuration?api_key=" + MoviesManager.apiKey
    fileprivate static let discoverMovieUrl = MoviesManager.baseUrl + "discover/movie"

    fileprivate let serialQueue = DispatchQueue(label: "GetTmdbSystemConfigurationInfoQueue")
    fileprivate var postersBaseUrl: String?

    private var movies = [Category: [Movie]]()
    private var imageViews = [UIImageView: Movie]()

    private init() {}

    //MARK: - Movies functions
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

    //MARK: - Posters functions
    func loadPoster(`in` imageView: UIImageView, `for` movie: Movie) {
        imageView.image = nil
        imageViews[imageView] = movie

        DispatchQueue.global(qos: .userInitiated).async {
            self.getTmdbSystemConfigurationInfo()
            guard let postersBaseUrl = self.postersBaseUrl,
                let imageUrl = URL(string: postersBaseUrl + movie.posterPath)
                else {
                    return
            }

            URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    let imageView = self.imageViews.filter { return $0.1 == movie }.first?.key
                    if nil != imageView {
                        imageView!.image = image
                        self.imageViews.removeValue(forKey: imageView!)
                    }
                }
                }.resume()
        }
    }

    private func getTmdbSystemConfigurationInfo() {
        if nil != postersBaseUrl { return }

        serialQueue.sync {
            if nil != postersBaseUrl { return }
            guard let url = URL(string: MoviesManager.configurationUrl) else { return }

            let semaphore = DispatchSemaphore(value: 0)
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data,
                    let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
                    let images = json["images"] as? [String: Any],
                    let baseUrl = images["secure_base_url"] as? String,
                    let posterSizes = images["poster_sizes"] as? [String] {
                    self.postersBaseUrl = baseUrl + self.selectPosterSize(posterSizes)
                }
                semaphore.signal()
                }.resume()
            _ = semaphore.wait(timeout: .distantFuture)
        }
    }

    private func selectPosterSize(_ posterSizes: [String]) -> String {
        var posterSize = posterSizes.last
        if posterSizes.count > 2 {
            posterSize = posterSizes[posterSizes.count - 3]
        }
        
        return posterSize ?? ""
    }

    private func presentMovies(`for` category: Category, `in` presenter: MoviesPresenter) {
        let movies = self.movies[category]
        presenter.present(movies)
    }
}
