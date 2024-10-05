//
//  MovieTableViewCell.swift
//  banquemisr.challenge05
//
//  Created by Engy on 10/3/24.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    @IBOutlet var layerView: UIView!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCornerRadius()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: true)
    }

    // MARK: - Configuration
    func config(with cell: Movie, category: MovieAPIProvider, imageData: Data? = nil) {
        titleLabel.text = cell.title
        releaseDateLabel.text = cell.releaseDate
        voteAverageLabel.text = formattedVoteAverage(cell.voteAverage)

        if let imageData = imageData {
            posterImageView.image = UIImage(data: imageData)
        } else {
            loadImage(for: cell)
        }
    }

    // MARK: - Private Methods
    private func setupCornerRadius() {
        [posterImageView, layerView].forEach { $0.layer.cornerRadius = 16 }
    }

    private func formattedVoteAverage(_ voteAverage: Double) -> String {
        return voteAverage != 0.0
            ? "★ " + String(format: "%0.1f", voteAverage)
            : "No Rating Yet"
    }

    private func loadImage(for cell: Movie) {
        let baseImgUrl = "https://image.tmdb.org/t/p/w342"

        guard let posterPath = URL(string: baseImgUrl + cell.posterPath) else {
            print("Error in image cell URL")
            posterImageView.image = UIImage(named: Constants.noPoster)
            return
        }

        posterImageView.image = UIImage(named: "loading")

        DispatchQueue.global(qos: .background).async { [weak self] in
            if let imageData = try? Data(contentsOf: posterPath) {
                DispatchQueue.main.async {
                    self?.posterImageView.image = UIImage(data: imageData)
                    MovieCoreDataManager.shared.storeMovieImage(imageData, forMovieWithId: cell.id, imageType: .poster)
                }
            } else {
                DispatchQueue.main.async {
                    self?.posterImageView.image = UIImage(named: Constants.noPoster)
                }
            }
        }
    }
}
