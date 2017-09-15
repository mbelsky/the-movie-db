//
//  Movie.swift
//  the-movie-db
//
//  Created by Maxim Belsky on 14/09/2017.
//  Copyright © 2017 Maxim Belsky. All rights reserved.
//

import Foundation

struct Movie: CustomStringConvertible {
    let
    id: Int,
    name: String,
    posterPath: String

    var description: String {
        return "name=\(name)"
    }

    init?(jsonDict: [String: Any]) {
        guard let id = jsonDict["id"] as? Int,
                let name = jsonDict["title"] as? String,
                let posterPath = jsonDict["poster_path"] as? String
        else {
            return nil
        }
        self.id = id
        self.name = name
        self.posterPath = posterPath
    }
}
