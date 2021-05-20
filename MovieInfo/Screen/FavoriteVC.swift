//
//  FavoriteVC.swift
//  MovieInfo
//
//  Created by Spencer Forrest on 09/05/2021.
//

import UIKit

class FavoriteVC: LoadingVC {

  private var tableView: UITableView!
  private var favorites = [Favorite]()
  

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Favorites"
    setupTableView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    favorites = PersistenceManager.singleton.getFavoritesSortedByTitleAsc()
    updateUI()
  }

  private func updateUI(isReloadDataNeeded: Bool = true, duration: TimeInterval = 0) {
    if favorites.isEmpty {
      setupEmptyStateOnMainQueue(message: EmptyState.favorite, animationDuration: duration)
    } else {
      removeEmptyStateOnMainQeue()
      if isReloadDataNeeded { tableView.reloadData() }
    }
  }

  private func setupTableView() {
    tableView = UITableView.init(frame: view.bounds)
    tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseIdentifier)

    tableView.dataSource = self
    tableView.delegate = self

    tableView.rowHeight = 100
    tableView.backgroundColor = Color.background
    tableView.separatorStyle = .none
    tableView.tableFooterView = UIView()

    view.addSubview(tableView)
  }
}


// MARK: UITableViewDataSource
extension FavoriteVC: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return favorites.count }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let favorite = favorites[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseIdentifier) as! FavoriteCell
    cell.set(title: favorite.title, posterPath: favorite.posterPath)
    
    return cell
  }
}


// MARK: UITableViewDelegate
extension FavoriteVC: UITableViewDelegate {

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete else { return }

    PersistenceManager.singleton.removeFromFavorite(movieId: favorites[indexPath.row].id) { [weak self] error in
      guard let self = self else { return }

      if let error = error {
        self.presentAlertOnMainQueue(body: error.rawValue)
      } else {
        self.removeFavorite(indexPath: indexPath)
      }
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedMovie = favorites[indexPath.row].convertToMovie()
    navigationController?.pushViewController(MovieVC.init(movie: selectedMovie), animated: true)
  }

  private func removeFavorite(indexPath: IndexPath) {
    self.favorites.remove(at: indexPath.row)

    DispatchQueue.main.async {
      self.tableView.deleteRows(at: [indexPath], with: .left)
      self.updateUI(isReloadDataNeeded: false, duration: 0.75)
    }
  }
}
