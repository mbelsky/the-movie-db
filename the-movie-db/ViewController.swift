//
//  ViewController.swift
//  the-movie-db
//
//  Created by Maxim Belsky on 14/09/2017.
//  Copyright © 2017 Maxim Belsky. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    fileprivate let labelPadding: CGFloat = 8
    fileprivate let cellId = "CategoryCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.contentInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0,
                                              right: 0)
        let tableHeaderView = UILabel()
        let titleFontSize = UIFont.preferredFont(forTextStyle: .title2).pointSize
        tableHeaderView.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        tableHeaderView.text = "Movies"
        tableHeaderView.sizeToFit()

        let containerFrame = CGRect(x: 0, y: 0, width: tableHeaderView.bounds.width + labelPadding,
                                    height: tableHeaderView.bounds.height + labelPadding)
        let tableHeaderViewContainer = UIView(frame: containerFrame)
        tableHeaderViewContainer.addSubview(tableHeaderView)
        tableHeaderView.frame.origin.x = labelPadding
        tableView.tableHeaderView = tableHeaderViewContainer
        tableView.tableFooterView = UIView()

        tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: cellId)
    }
}

//MARK: - TableView DataSource & Delegate methods
extension ViewController {
    private var sectionHeaderFont: UIFont {
        let fontSize = UIFont.preferredFont(forTextStyle: .headline).pointSize
        return UIFont.boldSystemFont(ofSize: fontSize)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeaderFont.lineHeight + labelPadding
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UILabel()
        header.font = sectionHeaderFont
        header.text = Category(rawValue: section)?.description
        header.sizeToFit()

        let container = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: header.bounds.height))
        container.addSubview(header)
        header.frame.origin.x = labelPadding

        return container
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? CategoryCell,
                let category = Category(rawValue: indexPath.section) else {
            fatalError()
        }
        cell.present(nil)
        MoviesManager.default.loadMovies(for: category, in: cell)

        return cell
    }
}

enum Category: Int, CustomStringConvertible {
    case new, popular, highest

    var description: String {
        switch self {
        case .new:
            return "New in Theatres"
        case .popular:
            return "Popular"
        case .highest:
            return "Highest Rated This Year"
        }
    }
}
